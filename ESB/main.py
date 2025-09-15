# import os
# import shutil
# import subprocess
# import tempfile
# import logging
# import uuid
# from fastapi import FastAPI, HTTPException, BackgroundTasks
# from fastapi.responses import FileResponse
# from pydantic import BaseModel

# # --- Configuration ---
# ISCC_PATH = r"C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
# ASSETS_PATH = os.path.join(os.path.dirname(__file__), "assets")

# # --- Data Model ---
# class RequestPayload(BaseModel):
#     LSC_MAC_ADDRESS: str
#     PARENT_SERVER_ID: str
#     INITIAL_PARENT_IP: str
#     BOOTSTRAP_TOKEN: str
#     OWNER_ADMIN_ID: str

# # --- FastAPI App ---
# app = FastAPI()
# logging.basicConfig(level=logging.INFO)

# # def update_env_file(file_path: str, data: RequestPayload):
# #     """Reads the .env template, replaces values, and writes it back."""
# #     try:
# #         print(data.BOOTSTRAP_TOKEN)
# #         print(data.OWNER_ADMIN_ID)
# #         print(data.INITIAL_PARENT_IP)
# #         print(data.LSC_MAC_ADDRESS)
# #         print(data.PARENT_SERVER_ID)
# #         with open(file_path, 'r') as f:
# #             content = f.read()
# #         content = content.replace('LSC_MAC_ADDRESS=', f'LSC_MAC_ADDRESS={data.LSC_MAC_ADDRESS}')
# #         content = content.replace('PARENT_SERVER_ID="', f'PARENT_SERVER_ID="{data.PARENT_SERVER_ID}"')
# #         content = content.replace('INITIAL_PARENT_IP=', f'INITIAL_PARENT_IP={data.INITIAL_PARENT_IP}')
# #         content = content.replace('BOOTSTRAP_TOKEN=', f'BOOTSTRAP_TOKEN={data.BOOTSTRAP_TOKEN}')
# #         content = content.replace('OWNER_ADMIN_ID=', f'OWNER_ADMIN_ID={data.OWNER_ADMIN_ID}')
# #         with open(file_path, 'w') as f:
# #             f.write(content)
# #     except IOError as e:
# #         logging.error(f"Error updating .env file: {e}")
# #         raise

# # In your FastAPI script

# def update_env_file(file_path: str, data: RequestPayload):
#     """
#     Reads the .env template line by line, replaces values, and writes it back.
#     This method is more robust than a simple string replace.
#     """
#     try:
#         with open(file_path, 'r') as f:
#             lines = f.readlines()

#         # Create a dictionary of the full, correct lines we want in the file
#         replacements = {
#             'LSC_MAC_ADDRESS': f'LSC_MAC_ADDRESS={data.LSC_MAC_ADDRESS}\n',
#             'PARENT_SERVER_ID': f'PARENT_SERVER_ID="{data.PARENT_SERVER_ID}"\n',
#             'INITIAL_PARENT_IP': f'INITIAL_PARENT_IP={data.INITIAL_PARENT_IP}\n',
#             'BOOTSTRAP_TOKEN': f'BOOTSTRAP_TOKEN={data.BOOTSTRAP_TOKEN}\n',
#             'OWNER_ADMIN_ID': f'OWNER_ADMIN_ID={data.OWNER_ADMIN_ID}\n',
#         }

#         new_lines = []
#         # Go through each line of the original file
#         for line in lines:
#             # Find the key by splitting the line at the first '='
#             key = line.split('=')[0].strip()
            
#             # If this key is one we want to replace, use our new, complete line
#             if key in replacements:
#                 new_lines.append(replacements[key])
#             # Otherwise (like for MCC_IP_ADDRESS), keep the original line
#             else:
#                 new_lines.append(line)

#         # Write the newly constructed lines back to the file
#         with open(file_path, 'w') as f:
#             f.writelines(new_lines)
            
#         logging.info(f"Successfully updated .env file at {file_path}")

#     except IOError as e:
#         logging.error(f"Error updating .env file: {e}")
#         raise
    
# def cleanup_folder(folder_path: str):
#     """A helper function to remove a directory tree."""
#     logging.info(f"Cleaning up temporary folder: {folder_path}")
#     shutil.rmtree(folder_path)

# @app.post("/generate-installer")
# async def generate_installer(payload: RequestPayload, background_tasks: BackgroundTasks):
#     # Create a temporary directory that we will manage manually
#     temp_dir = tempfile.mkdtemp()
#     logging.info(f"Processing request in temporary directory: {temp_dir}")
    
#     # Add the cleanup task to run AFTER the response is sent
#     background_tasks.add_task(cleanup_folder, temp_dir)

#     try:
#         # Step 1: Copy assets to the temporary directory
#         shutil.copytree(os.path.join(ASSETS_PATH, "flutter_app"), os.path.join(temp_dir, "flutter_app"))
#         shutil.copytree(os.path.join(ASSETS_PATH, "scripts"), os.path.join(temp_dir, "scripts"))
#         env_path_in_temp = os.path.join(temp_dir, "template.env")
#         shutil.copy(os.path.join(ASSETS_PATH, "template.env"), env_path_in_temp)
        
#         # Step 2: Update the .env file
#         update_env_file(env_path_in_temp, payload)
        
#         # Step 3: Compile the Inno Setup script
#         iss_script_path = os.path.join(ASSETS_PATH, "template.iss")
#         output_filename = "Bluck-Security-Setup.exe"
        
#         command = [ISCC_PATH, "/q", f"/o{temp_dir}", f"/dSourceDir={temp_dir}", iss_script_path]
        
#         result = subprocess.run(command, capture_output=True, text=True, encoding='latin-1')

#         if result.returncode != 0:
#             logging.error(f"Inno Setup failed! STDERR:\n{result.stderr}")
#             raise HTTPException(status_code=500, detail="Failed to build installer. See server logs.")

#         # Step 4: Return the generated file
#         final_exe_path = os.path.join(temp_dir, output_filename)
        
#         if not os.path.exists(final_exe_path):
#             logging.error(f"Build succeeded but output file is missing. STDOUT:\n{result.stdout}")
#             raise HTTPException(status_code=500, detail="Build finished, but output file was not created.")

#         return FileResponse(
#             path=final_exe_path,
#             media_type='application/vnd.microsoft.portable-executable',
#             filename=output_filename
#         )
#     except Exception as e:
#         # If any other error happens, still ensure cleanup
#         logging.error(f"An exception occurred during build: {e}")
#         raise HTTPException(status_code=500, detail=str(e))


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
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def cleanup_folder(folder_path: str):
    """A helper function to remove a directory tree."""
    logging.info(f"Cleaning up temporary folder: {folder_path}")
    shutil.rmtree(folder_path)

def create_final_env_file(temp_dir: str, data: RequestPayload):
    """
    Reads the .env template, replaces values, and writes the final .env file
    directly into the temporary directory.
    """
    try:
        template_path = os.path.join(ASSETS_PATH, "template.env")
        final_env_path = os.path.join(temp_dir, ".env")

        with open(template_path, 'r') as f:
            content = f.read()

        # Perform all the replacements in memory
        content = content.replace('LSC_MAC_ADDRESS=', f'LSC_MAC_ADDRESS={data.LSC_MAC_ADDRESS}')
        content = content.replace('PARENT_SERVER_ID="', f'PARENT_SERVER_ID="{data.PARENT_SERVER_ID}"')
        content = content.replace('INITIAL_PARENT_IP=', f'INITIAL_PARENT_IP={data.INITIAL_PARENT_IP}')
        content = content.replace('BOOTSTRAP_TOKEN=', f'BOOTSTRAP_TOKEN={data.BOOTSTRAP_TOKEN}')
        # Add a placeholder for OWNER_ADMIN_ID to your template.env if you need it
        content = content.replace('OWNER_ADMIN_ID=', f'OWNER_ADMIN_ID={data.OWNER_ADMIN_ID}')
        
        print(data.BOOTSTRAP_TOKEN)
        print(data.OWNER_ADMIN_ID)
        print(data.INITIAL_PARENT_IP)
        print(data.LSC_MAC_ADDRESS)
        print(data.PARENT_SERVER_ID)


        # Write the modified content to the new .env file in the temp directory
        with open(final_env_path, 'w') as f:
            f.write(content)
            
        logging.info(f"Successfully created final .env file at {final_env_path}")

    except IOError as e:
        logging.error(f"Error creating .env file: {e}")
        raise

@app.post("/generate-installer")
async def generate_installer(payload: RequestPayload, background_tasks: BackgroundTasks):
    temp_dir = tempfile.mkdtemp()
    logging.info(f"Processing request in temporary directory: {temp_dir}")
    
    background_tasks.add_task(cleanup_folder, temp_dir)

    try:
        # Step 1: Copy ONLY the necessary assets
        shutil.copytree(os.path.join(ASSETS_PATH, "flutter_app"), os.path.join(temp_dir, "flutter_app"))
        shutil.copytree(os.path.join(ASSETS_PATH, "scripts"), os.path.join(temp_dir, "scripts"))
        
        # Step 2: Create and update the .env file directly in the temp folder
        create_final_env_file(temp_dir, payload)
        
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
        logging.error(f"An exception occurred during build: {e}")
        raise HTTPException(status_code=500, detail=str(e))