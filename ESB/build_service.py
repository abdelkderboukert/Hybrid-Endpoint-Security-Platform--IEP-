# from flask import Flask, request, jsonify, send_file
# import os
# import subprocess
# import shutil
# import tempfile
# import zipfile
# from pathlib import Path
# import logging
# import threading
# import uuid
# from datetime import datetime
# import atexit
# import time

# # Configure logging
# logging.basicConfig(level=logging.INFO)
# logger = logging.getLogger(__name__)

# app = Flask(__name__)

# # Configuration
# PROJECT_ROOT = Path(__file__).parent.parent  # Assuming this script is in a 'build_service' folder
# BACKEND_PATH = PROJECT_ROOT / "ESB" / "backend"
# FRONTEND_PATH = PROJECT_ROOT / "ESB" / "frontend"
# SETTINGS_FILE = BACKEND_PATH / "backend" / "settings.py"
# SPEC_FILE = BACKEND_PATH / "DSEC_Local_Server.spec"
# DIST_PATH = BACKEND_PATH / "dist"
# ASSETS_BIN_PATH = FRONTEND_PATH / "assets" / "bin"
# INSTALLATION_PATH = FRONTEND_PATH / "installation"

# # Create temporary directory for builds
# TEMP_DIR = Path(tempfile.mkdtemp(prefix="lsc_builds_"))
# logger.info(f"Using temporary directory: {TEMP_DIR}")

# # Create necessary directories
# ASSETS_BIN_PATH.mkdir(parents=True, exist_ok=True)

# # Cleanup function to remove temp directory on exit
# def cleanup_temp_dir():
#     if TEMP_DIR.exists():
#         shutil.rmtree(TEMP_DIR)
#         logger.info(f"Cleaned up temporary directory: {TEMP_DIR}")

# atexit.register(cleanup_temp_dir)

# class BuildManager:
#     def __init__(self):
#         self.active_builds = {}
#         self.cleanup_thread = threading.Thread(target=self._cleanup_old_builds, daemon=True)
#         self.cleanup_thread.start()
    
#     def _cleanup_old_builds(self):
#         """Cleanup old builds periodically"""
#         while True:
#             try:
#                 current_time = datetime.now()
#                 builds_to_remove = []
                
#                 for build_id, build_info in self.active_builds.items():
#                     # Remove builds older than 1 hour or already downloaded
#                     build_time = datetime.fromisoformat(build_info['timestamp'])
#                     age_minutes = (current_time - build_time).total_seconds() / 60
                    
#                     if (age_minutes > 60 or 
#                         build_info.get('downloaded', False) or 
#                         build_info['status'] == 'failed'):
                        
#                         builds_to_remove.append(build_id)
                
#                 # Remove old builds and their files
#                 for build_id in builds_to_remove:
#                     self._remove_build(build_id)
                
#                 time.sleep(300)  # Check every 5 minutes
                
#             except Exception as e:
#                 logger.error(f"Error in cleanup thread: {str(e)}")
#                 time.sleep(60)
    
#     def _remove_build(self, build_id):
#         """Remove build and associated files"""
#         try:
#             # Remove installer file if it exists
#             installer_path = TEMP_DIR / f"Bluck_Security_{build_id}.exe"
#             if installer_path.exists():
#                 installer_path.unlink()
#                 logger.info(f"Deleted installer file for build {build_id}")
            
#             # Remove from active builds
#             if build_id in self.active_builds:
#                 del self.active_builds[build_id]
#                 logger.info(f"Removed build {build_id} from active builds")
                
#         except Exception as e:
#             logger.error(f"Error removing build {build_id}: {str(e)}")
    
#     def start_build(self, build_id, parent_server_id, parent_server_ip):
#         """Start the build process in a separate thread"""
#         build_thread = threading.Thread(
#             target=self._build_process,
#             args=(build_id, parent_server_id, parent_server_ip)
#         )
#         build_thread.start()
        
#         self.active_builds[build_id] = {
#             'status': 'started',
#             'progress': 0,
#             'message': 'Build process started',
#             'timestamp': datetime.now().isoformat(),
#             'downloaded': False,
#             'installer_path': None
#         }
    
#     def _build_process(self, build_id, parent_server_id, parent_server_ip):
#         """Main build process"""
#         try:
#             self._update_build_status(build_id, 'updating_settings', 10, 'Updating settings.py')
#             self._update_settings(parent_server_id, parent_server_ip)
            
#             self._update_build_status(build_id, 'building_backend', 20, 'Building backend with PyInstaller')
#             self._build_backend()
            
#             self._update_build_status(build_id, 'copying_files', 40, 'Copying files to frontend/assets/bin')
#             self._copy_backend_to_frontend()
            
#             self._update_build_status(build_id, 'building_flutter', 60, 'Building Flutter Windows app')
#             self._build_flutter()
            
#             self._update_build_status(build_id, 'creating_installer', 80, 'Creating installer with Inno Setup')
#             installer_path = self._create_installer(build_id)
            
#             self._update_build_status(build_id, 'completed', 100, 
#                                     f'Build completed: {installer_path.name}', installer_path)
            
#         except Exception as e:
#             logger.error(f"Build {build_id} failed: {str(e)}")
#             self._update_build_status(build_id, 'failed', -1, f'Build failed: {str(e)}')
    
#     def _update_build_status(self, build_id, status, progress, message, installer_path=None):
#         """Update build status"""
#         if build_id in self.active_builds:
#             self.active_builds[build_id].update({
#                 'status': status,
#                 'progress': progress,
#                 'message': message,
#                 'timestamp': datetime.now().isoformat()
#             })
            
#             if installer_path:
#                 self.active_builds[build_id]['installer_path'] = str(installer_path)
                
#         logger.info(f"Build {build_id}: {message}")
    
#     def _update_settings(self, parent_server_id, parent_server_ip):
#         """Update the settings.py file with new values"""
#         if not SETTINGS_FILE.exists():
#             raise FileNotFoundError(f"Settings file not found: {SETTINGS_FILE}")
        
#         # Read current settings
#         with open(SETTINGS_FILE, 'r') as f:
#             content = f.read()
        
#         # Update PARENT_SERVER_ID
#         if 'PARENT_SERVER_ID' in content:
#             # Replace existing value
#             import re
#             content = re.sub(
#                 r'PARENT_SERVER_ID\s*=.*',
#                 f'PARENT_SERVER_ID = "{parent_server_id}"',
#                 content
#             )
#         else:
#             # Add new value
#             content += f'\n\nPARENT_SERVER_ID = "{parent_server_id}"\n'
        
#         # Update PARENT_SERVER_IP
#         if 'PARENT_SERVER_IP' in content:
#             # Replace existing value
#             content = re.sub(
#                 r'PARENT_SERVER_IP\s*=.*',
#                 f'PARENT_SERVER_IP = "{parent_server_ip}"',
#                 content
#             )
#         else:
#             # Add new value
#             content += f'PARENT_SERVER_IP = "{parent_server_ip}"\n'
        
#         # Write updated settings
#         with open(SETTINGS_FILE, 'w') as f:
#             f.write(content)
        
#         logger.info(f"Updated settings: PARENT_SERVER_ID={parent_server_id}, PARENT_SERVER_IP={parent_server_ip}")
    
#     def _build_backend(self):
#         """Build backend using PyInstaller"""
#         if not SPEC_FILE.exists():
#             raise FileNotFoundError(f"Spec file not found: {SPEC_FILE}")
        
#         # Change to backend directory
#         original_cwd = os.getcwd()
#         os.chdir(BACKEND_PATH)
        
#         try:
#             # Run PyInstaller
#             result = subprocess.run([
#                 'pyinstaller',
#                 str(SPEC_FILE.name)
#             ], capture_output=True, text=True, check=True)
            
#             logger.info("PyInstaller completed successfully")
            
#         except subprocess.CalledProcessError as e:
#             raise Exception(f"PyInstaller failed: {e.stderr}")
#         finally:
#             os.chdir(original_cwd)
    
#     def _copy_backend_to_frontend(self):
#         """Copy backend dist files to frontend/assets/bin"""
#         if not DIST_PATH.exists():
#             raise FileNotFoundError(f"Dist directory not found: {DIST_PATH}")
        
#         # Remove existing files in assets/bin
#         if ASSETS_BIN_PATH.exists():
#             shutil.rmtree(ASSETS_BIN_PATH)
        
#         # Copy all contents from dist to assets/bin
#         shutil.copytree(DIST_PATH, ASSETS_BIN_PATH)
        
#         logger.info(f"Copied {DIST_PATH} to {ASSETS_BIN_PATH}")
    
#     def _build_flutter(self):
#         """Build Flutter Windows application"""

        
#         if not FRONTEND_PATH.exists():
#             raise FileNotFoundError(f"Frontend directory not found: {FRONTEND_PATH}")
        
#         # Change to frontend directory
#         original_cwd = os.getcwd()
#         os.chdir(FRONTEND_PATH)
        
#         try:
#             print("Building Flutter Windows application...")
#             # Run flutter build windows
#             result = subprocess.run([
#                 'flutter', 'build', 'windows'
#             ], capture_output=True, text=True, check=True)
            
#             logger.info("Flutter build completed successfully")
            
#         except subprocess.CalledProcessError as e:
#             raise Exception(f"Flutter build failed: {e.stderr}")
#         finally:
#             os.chdir(original_cwd)
    
#     def _create_installer(self, build_id):
#         """Create installer using Inno Setup"""
#         print("Creating installer with Inno Setup...")
#         iss_script = INSTALLATION_PATH / "desktop_script.iss"
        
#         if not iss_script.exists():
#             raise FileNotFoundError(f"Inno Setup script not found: {iss_script}")
        
#         # Change to installation directory
#         original_cwd = os.getcwd()
#         os.chdir(INSTALLATION_PATH)
        
#         try:
#             # Run Inno Setup Compiler
#             result = subprocess.run([
#                 'iscc',  # Inno Setup Compiler command
#                 str(iss_script.name)
#             ], capture_output=True, text=True, check=True)
            
#             logger.info("Inno Setup completed successfully")
            
#             # Find the generated installer (usually in Output folder)
#             output_folder = INSTALLATION_PATH / "Output"
#             if output_folder.exists():
#                 installer_files = list(output_folder.glob("*.exe"))
#                 if installer_files:
#                     # Copy installer to temp directory with unique name
#                     installer_source = installer_files[0]
#                     installer_dest = TEMP_DIR / f"Bluck_Security_{build_id}.exe"
#                     shutil.copy2(installer_source, installer_dest)
                    
#                     # Clean up the original installer from Output folder
#                     installer_source.unlink()
#                     logger.info(f"Moved installer to temporary location: {installer_dest}")
                    
#                     return installer_dest
            
#             raise Exception("Installer file not found after Inno Setup compilation")
            
#         except subprocess.CalledProcessError as e:
#             raise Exception(f"Inno Setup failed: {e.stderr}")
#         finally:
#             os.chdir(original_cwd)

# # Initialize build manager
# build_manager = BuildManager()

# @app.route('/build', methods=['POST'])
# def start_build():
#     """Start a new build process"""
#     try:
#         data = request.get_json()
        
#         if not data:
#             return jsonify({'error': 'No JSON data provided'}), 400
        
#         parent_server_id = data.get('PARENT_SERVER_ID')
#         parent_server_ip = data.get('PARENT_SERVER_IP')
        
#         if not parent_server_id or not parent_server_ip:
#             return jsonify({
#                 'error': 'PARENT_SERVER_ID and PARENT_SERVER_IP are required'
#             }), 400
        
#         # Generate unique build ID
#         build_id = str(uuid.uuid4())
        
#         # Start build process
#         build_manager.start_build(build_id, parent_server_id, parent_server_ip)
        
#         return jsonify({
#             'build_id': build_id,
#             'status': 'started',
#             'message': 'Build process initiated'
#         }), 202
        
#     except Exception as e:
#         logger.error(f"Error starting build: {str(e)}")
#         return jsonify({'error': str(e)}), 500

# @app.route('/build/<build_id>/status', methods=['GET'])
# def get_build_status(build_id):
#     """Get build status"""
#     if build_id not in build_manager.active_builds:
#         return jsonify({'error': 'Build not found'}), 404
    
#     return jsonify(build_manager.active_builds[build_id])

# @app.route('/build/<build_id>/download', methods=['GET'])
# def download_build(build_id):
#     """Download completed build and mark for cleanup"""
#     if build_id not in build_manager.active_builds:
#         return jsonify({'error': 'Build not found'}), 404
    
#     build_info = build_manager.active_builds[build_id]
#     if build_info['status'] != 'completed':
#         return jsonify({'error': 'Build not completed yet'}), 400
    
#     installer_path = Path(build_info['installer_path'])
    
#     if not installer_path.exists():
#         return jsonify({'error': 'Installer file not found'}), 404
    
#     # Mark as downloaded for cleanup
#     build_manager.active_builds[build_id]['downloaded'] = True
#     logger.info(f"Build {build_id} marked for cleanup after download")
    
#     # Schedule cleanup after a short delay to ensure download completes
#     def delayed_cleanup():
#         time.sleep(30)  # Wait 30 seconds after download starts
#         build_manager._remove_build(build_id)
    
#     cleanup_thread = threading.Thread(target=delayed_cleanup, daemon=True)
#     cleanup_thread.start()
    
#     return send_file(
#         installer_path,
#         as_attachment=True,
#         download_name="Bluck_Security.exe",
#         mimetype='application/octet-stream'
#     )

# @app.route('/builds', methods=['GET'])
# def list_builds():
#     """List all builds"""
#     return jsonify(build_manager.active_builds)

# @app.route('/health', methods=['GET'])
# def health_check():
#     """Health check endpoint"""
#     return jsonify({
#         'status': 'healthy',
#         'timestamp': datetime.now().isoformat(),
#         'temp_dir': str(TEMP_DIR),
#         'active_builds': len(build_manager.active_builds)
#     })

# @app.route('/cleanup', methods=['POST'])
# def manual_cleanup():
#     """Manual cleanup endpoint for testing"""
#     cleaned_builds = []
#     for build_id in list(build_manager.active_builds.keys()):
#         build_info = build_manager.active_builds[build_id]
#         if (build_info['status'] in ['completed', 'failed'] or 
#             build_info.get('downloaded', False)):
#             build_manager._remove_build(build_id)
#             cleaned_builds.append(build_id)
    
#     return jsonify({
#         'cleaned_builds': cleaned_builds,
#         'remaining_builds': len(build_manager.active_builds)
#     })

# if __name__ == '__main__':
#     # Check dependencies
#     required_tools = ['pyinstaller', 'flutter', 'iscc']
#     missing_tools = []
    
#     for tool in required_tools:
#         try:
#             subprocess.run([tool, '--version'], capture_output=True, check=True)
#         except (subprocess.CalledProcessError, FileNotFoundError):
#             missing_tools.append(tool)
    
#     if missing_tools:
#         logger.warning(f"Missing tools: {', '.join(missing_tools)}")
#         logger.warning("Please install missing tools before running the service")
    
#     app.run(host='0.0.0.0', port=5000, debug=False)

from flask import Flask, request, jsonify, send_file
import os
import subprocess
import shutil
import tempfile
import uuid
from pathlib import Path
import logging
import threading
from datetime import datetime, timedelta
import atexit
import time
import re

# --- Basic Configuration ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)

# --- Path Configuration ---
# The root of the entire project (e.g., D-SEC_Project/)
PROJECT_SOURCE_ROOT = Path(__file__).resolve().parent.parent 
# The directory containing the actual source code to be copied for each build
# Assuming the structure is D-SEC_Project/ESB/
CODE_TO_BUILD_PATH = PROJECT_SOURCE_ROOT / "ESB" 

# --- Build Environment Configuration ---
# Create a main directory to hold all temporary build environments
BUILD_ROOT_DIR = Path(tempfile.mkdtemp(prefix="lsc_build_root_"))
# Create a directory to store final, downloadable installers
DOWNLOAD_DIR = BUILD_ROOT_DIR / "downloads"
DOWNLOAD_DIR.mkdir()
logger.info(f"Using build root directory: {BUILD_ROOT_DIR}")

# --- Cleanup on Exit ---
def cleanup_on_exit():
    """Ensures the entire build root directory is removed when the app stops."""
    if BUILD_ROOT_DIR.exists():
        shutil.rmtree(BUILD_ROOT_DIR)
        logger.info(f"Cleaned up main build directory on exit: {BUILD_ROOT_DIR}")

atexit.register(cleanup_on_exit)


class BuildManager:
    def __init__(self):
        self.active_builds = {}
        self.lock = threading.Lock()
        self.cleanup_thread = threading.Thread(target=self._periodic_cleanup, daemon=True)
        self.cleanup_thread.start()

    def _periodic_cleanup(self):
        """Periodically cleans up old, failed, or downloaded builds."""
        while True:
            try:
                current_time = datetime.now()
                builds_to_remove = []
                
                with self.lock:
                    for build_id, build_info in self.active_builds.items():
                        build_time = datetime.fromisoformat(build_info['timestamp'])
                        age = current_time - build_time
                        
                        # Cleanup conditions: older than 1 hour, downloaded, or failed
                        if (age > timedelta(hours=1) or 
                            build_info.get('downloaded', False) or 
                            build_info['status'] == 'failed'):
                            builds_to_remove.append(build_id)
                
                if builds_to_remove:
                    logger.info(f"Found {len(builds_to_remove)} builds for cleanup: {', '.join(builds_to_remove)}")
                    for build_id in builds_to_remove:
                        self._remove_build(build_id)
                        
                time.sleep(300)  # Check every 5 minutes
            except Exception as e:
                logger.error(f"Error in cleanup thread: {e}", exc_info=True)
                time.sleep(60)

    def _remove_build(self, build_id):
        """Safely removes all artifacts associated with a build."""
        with self.lock:
            build_info = self.active_builds.pop(build_id, None)
        
        if not build_info:
            logger.warning(f"Attempted to remove build {build_id}, but it was not found in active builds.")
            return

        try:
            # 1. Delete the installer file
            installer_path = build_info.get('installer_path')
            if installer_path and Path(installer_path).exists():
                Path(installer_path).unlink()
                logger.info(f"Deleted installer for build {build_id} at {installer_path}")

            # 2. Delete the entire temporary build directory
            build_dir = build_info.get('build_dir')
            if build_dir and Path(build_dir).exists():
                shutil.rmtree(build_dir)
                logger.info(f"Deleted build directory for build {build_id} at {build_dir}")

            logger.info(f"Successfully cleaned up all artifacts for build {build_id}.")
        except Exception as e:
            logger.error(f"Error during cleanup of build {build_id}: {e}", exc_info=True)

    def start_build(self, parent_server_id, parent_server_ip):
        """Initiates a new, isolated build process."""
        build_id = str(uuid.uuid4())
        build_dir = BUILD_ROOT_DIR / build_id
        
        try:
            # --- Step 1: Create isolated environment by copying source code ---
            logger.info(f"[{build_id}] Creating isolated build environment at: {build_dir}")
            
            # Ignore patterns to avoid copying unnecessary files
            ignore = shutil.ignore_patterns(
                '.git', '__pycache__', '*.pyc', '.idea', 'build_service', 'Output'
            )
            shutil.copytree(CODE_TO_BUILD_PATH, build_dir, ignore=ignore, dirs_exist_ok=True)
            logger.info(f"[{build_id}] Source code copied successfully.")

        except Exception as e:
            logger.error(f"[{build_id}] Failed to create build environment: {e}", exc_info=True)
            # Clean up the partially created directory if copy failed
            if build_dir.exists():
                shutil.rmtree(build_dir)
            raise  # Re-raise the exception to be caught by the Flask route

        # --- Step 2: Start the build in a new thread ---
        build_thread = threading.Thread(
            target=self._build_process_wrapper,
            args=(build_id, build_dir, parent_server_id, parent_server_ip)
        )
        
        with self.lock:
            self.active_builds[build_id] = {
                'status': 'started',
                'progress': 5,
                'message': 'Build environment created. Starting process...',
                'timestamp': datetime.now().isoformat(),
                'downloaded': False,
                'build_dir': str(build_dir),
                'installer_path': None
            }
        
        build_thread.start()
        return build_id

    def _build_process_wrapper(self, build_id, build_dir, parent_server_id, parent_server_ip):
        """A wrapper to handle exceptions within the build thread."""
        try:
            self._build_process(build_id, build_dir, parent_server_id, parent_server_ip)
        except Exception as e:
            error_message = f"Build failed: {e}"
            logger.error(f"[{build_id}] {error_message}", exc_info=True)
            self._update_build_status(build_id, 'failed', -1, error_message)

    def _update_build_status(self, build_id, status, progress, message, installer_path=None):
        """Thread-safe method to update the status of a build."""
        with self.lock:
            if build_id in self.active_builds:
                self.active_builds[build_id].update({
                    'status': status,
                    'progress': progress,
                    'message': message,
                    'timestamp': datetime.now().isoformat()
                })
                if installer_path:
                    self.active_builds[build_id]['installer_path'] = str(installer_path)
        logger.info(f"[{build_id}] Progress {progress}%: {message}")

    # --- Core Build Steps (Operating in Isolated Directory) ---

    def _build_process(self, build_id, build_dir, parent_server_id, parent_server_ip):
        """The main sequence of build steps, all paths are relative to `build_dir`."""
        # Define paths within the isolated build directory
        backend_path = build_dir / "backend"
        frontend_path = build_dir / "frontend"
        settings_file = backend_path / "backend" / "settings.py"
        spec_file = backend_path / "DSEC_Local_Server.spec"
        dist_path = backend_path / "dist"
        assets_bin_path = frontend_path / "assets" / "bin"
        installation_path = frontend_path / "installation"

        # Step 1: Update settings.py
        self._update_build_status(build_id, 'updating_settings', 10, 'Updating settings.py')
        self._update_settings(settings_file, parent_server_id, parent_server_ip)

        # Step 2: Build backend with PyInstaller
        self._update_build_status(build_id, 'building_backend', 20, 'Building backend with PyInstaller')
        self._run_command(['pyinstaller', spec_file.name], cwd=backend_path)

        # Step 3: Copy backend files to frontend assets
        self._update_build_status(build_id, 'copying_files', 40, 'Copying backend to frontend assets')
        if assets_bin_path.exists(): shutil.rmtree(assets_bin_path)
        shutil.copytree(dist_path, assets_bin_path)

        # Step 4: Build Flutter application
        self._update_build_status(build_id, 'building_flutter', 60, 'Building Flutter Windows app')
        self._run_command(['flutter', 'build', 'windows'], cwd=frontend_path)

        # Step 5: Create installer with Inno Setup
        self._update_build_status(build_id, 'creating_installer', 80, 'Creating installer with Inno Setup')
        installer_path = self._create_installer(build_id, installation_path)

        # Final Step: Mark as complete
        self._update_build_status(build_id, 'completed', 100, f'Build completed successfully!', installer_path)

    def _update_settings(self, settings_file_path, parent_server_id, parent_server_ip):
        """Updates the settings.py file in the isolated build directory."""
        if not settings_file_path.exists():
            raise FileNotFoundError(f"Settings file not found: {settings_file_path}")
        
        with open(settings_file_path, 'r+') as f:
            content = f.read()
            content = re.sub(r'PARENT_SERVER_ID\s*=.*', f'PARENT_SERVER_ID = "{parent_server_id}"', content)
            content = re.sub(r'PARENT_SERVER_IP\s*=.*', f'PARENT_SERVER_IP = "{parent_server_ip}"', content)
            f.seek(0)
            f.write(content)
            f.truncate()

    def _run_command(self, command, cwd):
        """Executes a command in a specified directory and raises an error on failure."""
        try:
            result = subprocess.run(command, cwd=cwd, capture_output=True, text=True, check=True, encoding='utf-8')
            logger.info(f"Command '{' '.join(command)}' succeeded in '{cwd}'.")
            return result
        except subprocess.CalledProcessError as e:
            error_details = f"Command '{' '.join(command)}' failed in '{cwd}'.\nSTDOUT: {e.stdout}\nSTDERR: {e.stderr}"
            raise Exception(error_details)
        except FileNotFoundError:
            raise FileNotFoundError(f"Command '{command[0]}' not found. Is it installed and in your system's PATH?")

    def _create_installer(self, build_id, installation_path):
        """Creates the installer and moves it to the central download directory."""
        iss_script = installation_path / "desktop_script.iss"
        if not iss_script.exists():
            raise FileNotFoundError(f"Inno Setup script not found: {iss_script}")

        self._run_command(['iscc', iss_script.name], cwd=installation_path)
        
        output_folder = installation_path / "Output"
        installer_files = list(output_folder.glob("*.exe"))
        
        if not installer_files:
            raise Exception("Installer file not found after Inno Setup compilation.")
        
        # Move installer to central download location with a unique name
        source_installer = installer_files[0]
        dest_installer = DOWNLOAD_DIR / f"Bluck_Security_LSC_{build_id}.exe"
        shutil.move(source_installer, dest_installer)
        logger.info(f"Moved final installer to: {dest_installer}")
        
        return dest_installer

build_manager = BuildManager()


# --- Flask API Endpoints ---

@app.route('/build', methods=['POST'])
def handle_build_request():
    """Starts a new build process."""
    data = request.get_json()
    if not data or 'PARENT_SERVER_ID' not in data or 'PARENT_SERVER_IP' not in data:
        return jsonify({'error': 'PARENT_SERVER_ID and PARENT_SERVER_IP are required'}), 400
    
    try:
        build_id = build_manager.start_build(
            data['PARENT_SERVER_ID'],
            data['PARENT_SERVER_IP']
        )
        return jsonify({
            'build_id': build_id,
            'status': 'started',
            'message': 'Build process initiated. Check status endpoint for progress.'
        }), 202
    except Exception as e:
        logger.error(f"Failed to start build process: {e}", exc_info=True)
        return jsonify({'error': f'Failed to start build: {e}'}), 500

@app.route('/build/<build_id>/status', methods=['GET'])
def get_build_status(build_id):
    """Gets the status of a specific build."""
    with build_manager.lock:
        build_info = build_manager.active_builds.get(build_id)
    
    if not build_info:
        return jsonify({'error': 'Build not found'}), 404
    
    return jsonify(build_info)

@app.route('/build/<build_id>/download', methods=['GET'])
def download_build(build_id):
    """Downloads the completed installer and marks it for cleanup."""
    with build_manager.lock:
        build_info = build_manager.active_builds.get(build_id)

    if not build_info:
        return jsonify({'error': 'Build not found'}), 404
    if build_info['status'] != 'completed':
        return jsonify({'error': 'Build is not yet complete'}), 400
    
    installer_path = Path(build_info['installer_path'])
    if not installer_path.exists():
        logger.error(f"Installer file for build {build_id} not found at expected path: {installer_path}")
        return jsonify({'error': 'Installer file is missing, the build may have been cleaned up.'}), 404
    
    # Mark as downloaded for the cleanup thread
    with build_manager.lock:
        if build_id in build_manager.active_builds:
            build_manager.active_builds[build_id]['downloaded'] = True
    
    logger.info(f"[{build_id}] Download initiated. Build is now marked for cleanup.")

    return send_file(
        installer_path,
        as_attachment=True,
        download_name="Bluck_Security_LSC_Installer.exe",
        mimetype='application/vnd.microsoft.portable-executable'
    )

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    with build_manager.lock:
        active_build_count = len(build_manager.active_builds)
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'build_root': str(BUILD_ROOT_DIR),
        'active_builds': active_build_count
    })


if __name__ == '__main__':
    # Initial dependency check
    for tool in ['pyinstaller', 'flutter', 'iscc']:
        if not shutil.which(tool):
            logger.error(f"FATAL: Required tool '{tool}' not found in system PATH. Please install it.")
            exit(1)
            
    logger.info("All required tools (pyinstaller, flutter, iscc) found.")
    app.run(host='0.0.0.0', port=5000, debug=False)