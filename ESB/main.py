import os
import shutil
import subprocess
import tempfile
import logging
import uuid
from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.responses import FileResponse
from pydantic import BaseModel

# --- Configuration ---
ISCC_PATH = r"C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
ASSETS_PATH = os.path.join(os.path.dirname(__file__), "assets")

# --- Data Model ---
class RequestPayload(BaseModel):
    LSC_MAC_ADDRESS: str
    PARENT_SERVER_ID: str
    INITIAL_PARENT_IP: str
    BOOTSTRAP_TOKEN: str
    OWNER_ADMIN_ID: str

# --- FastAPI App ---
app = FastAPI()
logging.basicConfig(level=logging.INFO)

def update_env_file(file_path: str, data: RequestPayload):
    """Reads the .env template, replaces values, and writes it back."""
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        content = content.replace('LSC_MAC_ADDRESS=', f'LSC_MAC_ADDRESS={data.LSC_MAC_ADDRESS}')
        content = content.replace('PARENT_SERVER_ID="', f'PARENT_SERVER_ID="{data.PARENT_SERVER_ID}"')
        content = content.replace('INITIAL_PARENT_IP=', f'INITIAL_PARENT_IP={data.INITIAL_PARENT_IP}')
        content = content.replace('BOOTSTRAP_TOKEN=', f'BOOTSTRAP_TOKEN={data.BOOTSTRAP_TOKEN}')
        content = content.replace('OWNER_ADMIN_ID=', f'OWNER_ADMIN_ID={data.OWNER_ADMIN_ID}')
        with open(file_path, 'w') as f:
            f.write(content)
    except IOError as e:
        logging.error(f"Error updating .env file: {e}")
        raise

def cleanup_folder(folder_path: str):
    """A helper function to remove a directory tree."""
    logging.info(f"Cleaning up temporary folder: {folder_path}")
    shutil.rmtree(folder_path)

@app.post("/generate-installer")
async def generate_installer(payload: RequestPayload, background_tasks: BackgroundTasks):
    # Create a temporary directory that we will manage manually
    temp_dir = tempfile.mkdtemp()
    logging.info(f"Processing request in temporary directory: {temp_dir}")
    
    # Add the cleanup task to run AFTER the response is sent
    background_tasks.add_task(cleanup_folder, temp_dir)

    try:
        # Step 1: Copy assets to the temporary directory
        shutil.copytree(os.path.join(ASSETS_PATH, "flutter_app"), os.path.join(temp_dir, "flutter_app"))
        shutil.copytree(os.path.join(ASSETS_PATH, "scripts"), os.path.join(temp_dir, "scripts"))
        env_path_in_temp = os.path.join(temp_dir, "template.env")
        shutil.copy(os.path.join(ASSETS_PATH, "template.env"), env_path_in_temp)
        
        # Step 2: Update the .env file
        update_env_file(env_path_in_temp, payload)
        
        # Step 3: Compile the Inno Setup script
        iss_script_path = os.path.join(ASSETS_PATH, "template.iss")
        output_filename = "Bluck-Security-Setup.exe"
        
        command = [ISCC_PATH, "/q", f"/o{temp_dir}", f"/dSourceDir={temp_dir}", iss_script_path]
        
        result = subprocess.run(command, capture_output=True, text=True, encoding='latin-1')

        if result.returncode != 0:
            logging.error(f"Inno Setup failed! STDERR:\n{result.stderr}")
            raise HTTPException(status_code=500, detail="Failed to build installer. See server logs.")

        # Step 4: Return the generated file
        final_exe_path = os.path.join(temp_dir, output_filename)
        
        if not os.path.exists(final_exe_path):
            logging.error(f"Build succeeded but output file is missing. STDOUT:\n{result.stdout}")
            raise HTTPException(status_code=500, detail="Build finished, but output file was not created.")

        return FileResponse(
            path=final_exe_path,
            media_type='application/vnd.microsoft.portable-executable',
            filename=output_filename
        )
    except Exception as e:
        # If any other error happens, still ensure cleanup
        logging.error(f"An exception occurred during build: {e}")
        raise HTTPException(status_code=500, detail=str(e))