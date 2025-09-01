import os
import re
import shutil
import subprocess
from flask import Flask, request, jsonify, send_from_directory

app = Flask(__name__)

# Define paths relative to the builder-server directory
PROJECT_REPO = "LSC"
BACKEND_DIR = os.path.join(PROJECT_REPO, "backend")
FRONTEND_DIR = os.path.join(PROJECT_REPO, "frontend")
SETTINGS_FILE = os.path.join(BACKEND_DIR, "config", "settings.py")
PYINSTALLER_SPEC = "DSEC_Local_Server.spec"
INNO_SCRIPT = os.path.join(FRONTEND_DIR, "installation", "desktop_script.iss")
BUILDS_FOLDER = "builds"

@app.route("/build", methods=["POST"])
def build_project():
    """Endpoint to trigger the full build process."""
    data = request.json
    new_ip = data.get("parent_server_ip")

    if not new_ip:
        return jsonify({"error": "No IP provided"}), 400

    try:
        # Clone a fresh copy of the repo for each build to prevent conflicts
        build_id = f"build-{os.urandom(4).hex()}"
        temp_project_path = os.path.join("/tmp", build_id)
        shutil.copytree(PROJECT_REPO, temp_project_path)
        
        # Pass the new IP and the temporary project path to the build function
        installer_filename = execute_build_process(new_ip, temp_project_path)

        # Move the final installer to the public builds folder
        final_installer_path = os.path.join(BUILDS_FOLDER, installer_filename)
        shutil.move(os.path.join(temp_project_path, "frontend", "installation", installer_filename), final_installer_path)

        # Clean up the temporary project directory
        shutil.rmtree(temp_project_path)
        
        return jsonify({
            "status": "success",
            "message": "Full project built and ready for download",
            "download_link": f"/download/{installer_filename}"
        })

    except subprocess.CalledProcessError as e:
        return jsonify({
            "status": "error",
            "message": f"Build process failed at {e.cmd}",
            "details": e.stderr.decode('utf-8')
        }), 500
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route("/download/<path:filename>", methods=["GET"])
def download_file(filename):
    """Endpoint to download the final installer."""
    return send_from_directory(BUILDS_FOLDER, filename, as_attachment=True)

def execute_build_process(ip, project_path):
    """Orchestrates all build steps."""
    
    # --- Step 1: Modify settings.py ---
    settings_path = os.path.join(project_path, "backend", "config", "settings.py")
    with open(settings_path, 'r') as file:
        content = file.read()
    pattern = r'(PARENT_SERVER\s*=\s*).*'
    new_line = f'PARENT_SERVER = "{ip}"'
    modified_content = re.sub(pattern, new_line, content)
    with open(settings_path, 'w') as file:
        file.write(modified_content)
    
    # --- Step 2: Run PyInstaller ---
    print("Running PyInstaller...")
    pyinstaller_spec_path = os.path.join(project_path, "backend", PYINSTALLER_SPEC)
    subprocess.run(["pyinstaller", pyinstaller_spec_path], check=True, cwd=os.path.join(project_path, "backend"), capture_output=True)
    
    # --- Step 3: Copy backend to frontend assets ---
    print("Copying backend files...")
    source_dir = os.path.join(project_path, "backend", "dist", "DSEC_Local_Server")
    dest_dir = os.path.join(project_path, "frontend", "assets", "bin")
    
    # Clean and copy files
    if os.path.exists(dest_dir):
        shutil.rmtree(dest_dir)
    shutil.copytree(source_dir, dest_dir)
    
    # --- Step 4: Build Flutter app for Windows ---
    print("Building Flutter app...")
    subprocess.run(["flutter", "build", "windows"], check=True, cwd=FRONTEND_DIR, capture_output=True)
    
    # --- Step 5: Build Inno Setup installer ---
    print("Building Inno Setup installer...")
    installer_script_path = os.path.join(project_path, "frontend", "installation", "desktop_script.iss")
    subprocess.run(["iscc", installer_script_path], check=True, cwd=os.path.join(project_path, "frontend", "installation"), capture_output=True)

    # Inno Setup saves the installer to a specific path defined in the .iss script
    # This example assumes the output filename is hardcoded or predictable
    inno_output_dir = os.path.join(project_path, "frontend", "installation", "Output")
    installer_files = [f for f in os.listdir(inno_output_dir) if f.endswith(".exe")]
    if not installer_files:
        raise Exception("Inno Setup did not produce an installer file.")
    
    return installer_files[0]

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)