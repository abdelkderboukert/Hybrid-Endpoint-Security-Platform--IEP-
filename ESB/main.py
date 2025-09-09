# import os
# import shutil
# import subprocess
# import tempfile
# import logging
# from fastapi import FastAPI, HTTPException
# from fastapi.responses import FileResponse
# from pydantic import BaseModel

# # --- Configuration ---
# # IMPORTANT: Update this path to where Inno Setup is installed on your server.
# ISCC_PATH = r"C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
# # The server automatically finds the 'assets' folder relative to its own location.
# ASSETS_PATH = os.path.join(os.path.dirname(__file__), "assets")


# # --- Data Validation Model ---
# class RequestPayload(BaseModel):
#     LSC_MAC_ADDRESS: str
#     PARENT_SERVER_ID: str
#     INITIAL_PARENT_IP: str
#     BOOTSTRAP_TOKEN: str


# # --- Initialize FastAPI App ---
# app = FastAPI()
# logging.basicConfig(level=logging.INFO)


# def update_env_file(file_path: str, data: RequestPayload):
#     """Reads the .env template, replaces values, and writes it back."""
#     try:
#         with open(file_path, 'r') as f:
#             content = f.read()
        
#         # Replace placeholders with data from the request payload
#         content = content.replace('LSC_MAC_ADDRESS=', f'LSC_MAC_ADDRESS={data.LSC_MAC_ADDRESS}')
#         content = content.replace('PARENT_SERVER_ID="', f'PARENT_SERVER_ID="{data.PARENT_SERVER_ID}"')
#         content = content.replace('INITIAL_PARENT_IP=', f'INITIAL_PARENT_IP={data.INITIAL_PARENT_IP}')
#         content = content.replace('BOOTSTRAP_TOKEN=', f'BOOTSTRAP_TOKEN={data.BOOTSTRAP_TOKEN}')
        
#         with open(file_path, 'w') as f:
#             f.write(content)
#     except IOError as e:
#         logging.error(f"Error updating .env file: {e}")
#         raise

# @app.post("/generate-installer")
# async def generate_installer(payload: RequestPayload):
#     """
#     Endpoint to generate a custom installer on the fly.
#     """
#     # Use a temporary directory that is automatically created and destroyed.
#     # This is key for handling multiple requests safely and concurrently.
#     with tempfile.TemporaryDirectory() as temp_dir:
#         logging.info(f"Processing request for MAC {payload.LSC_MAC_ADDRESS} in {temp_dir}")
        
#         # Step 1: Copy all required assets to the temporary directory
#         try:
#             shutil.copytree(os.path.join(ASSETS_PATH, "flutter_app"), os.path.join(temp_dir, "flutter_app"))
#             shutil.copytree(os.path.join(ASSETS_PATH, "scripts"), os.path.join(temp_dir, "scripts"))
#             env_path_in_temp = os.path.join(temp_dir, "template.env")
#             shutil.copy(os.path.join(ASSETS_PATH, "template.env"), env_path_in_temp)
#         except Exception as e:
#             logging.error(f"Failed to copy assets: {e}")
#             raise HTTPException(status_code=500, detail="Server asset configuration error.")

#         # Step 2: Update the .env file in the temp folder with user data
#         update_env_file(env_path_in_temp, payload)
        
#         # Step 3: Compile the Inno Setup script
#         iss_script_path = os.path.join(ASSETS_PATH, "template.iss")
#         output_filename = "Bluck-Security-Setup.exe"
        
#         # This list contains all options for the compiler
#         command = [
#             ISCC_PATH,
#             "/q",  # Quiet mode (no GUI)
#             f"/o{temp_dir}",  # Set the OUTPUT directory to our temp folder
#             f"/dSourceDir={temp_dir}", # Define our custom variable for the .iss script
#         ]
        
#         # try:
#         #     logging.info("Compiling installer with command arguments: %s", command)
#         #     # The script path MUST be the final argument. We add it here.
#         #     subprocess.run(
#         #         command + [iss_script_path], 
#         #         check=True, 
#         #         capture_output=True, 
#         #         text=True
#         #     )
#         # except subprocess.CalledProcessError as e:
#         #     # This will now give a more detailed error log if it fails
#         #     logging.error(f"Inno Setup compilation failed:\nArguments: {e.args}\nSTDOUT:\n{e.stdout}\nSTDERR:\n{e.stderr}")
#         #     raise HTTPException(status_code=500, detail=f"Failed to build installer: {e.stderr}")
#         # except FileNotFoundError:
#         #     logging.error(f"Compiler not found at {ISCC_PATH}. Please check the path in main.py.")
#         #     raise HTTPException(status_code=500, detail="Compiler not found on server.")


#         try:
#             logging.info("Compiling installer...")
            
#             # Execute the command and capture the result
#             result = subprocess.run(
#                 command + [iss_script_path], 
#                 capture_output=True, 
#                 text=True
#             )

#             # ALWAYS log the output from the compiler for debugging
#             if result.stdout:
#                 logging.info(f"Inno Setup STDOUT:\n{result.stdout}")
#             if result.stderr:
#                 logging.warning(f"Inno Setup STDERR:\n{result.stderr}")

#             # Manually check if the command failed
#             if result.returncode != 0:
#                 raise subprocess.CalledProcessError(result.returncode, command, result.stdout, result.stderr)

#         except subprocess.CalledProcessError as e:
#             logging.error(f"Inno Setup compilation failed with exit code {e.returncode}.")
#             raise HTTPException(status_code=500, detail="Failed to build installer. Check server logs for details.")
#         except FileNotFoundError:
#             logging.error(f"Compiler not found at {ISCC_PATH}. Please check the path in main.py.")
#             raise HTTPException(status_code=500, detail="Compiler not found on server.")
        
#         # Step 4: Stream the generated executable back to the user
#         final_exe_path = os.path.join(temp_dir, output_filename)
#         logging.info(f"Build successful. Sending file: {final_exe_path}")
        
#         return FileResponse(
#             path=final_exe_path,
#             media_type='application/vnd.microsoft.portable-executable',
#             filename=output_filename
#         )


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