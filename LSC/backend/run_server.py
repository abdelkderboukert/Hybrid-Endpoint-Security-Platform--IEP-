# import os
# import sys
# import io
# import contextlib
# from django.core.management import execute_from_command_line

# if __name__ == "__main__":
#     os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backend.settings")

#     # Check if the database file exists
#     db_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'db.sqlite3')
#     if not os.path.exists(db_path):
#         print("Database not found. Running migrations...")
#         with contextlib.redirect_stdout(io.StringIO()):
#             execute_from_command_line(['manage.py', 'migrate'])
#         print("Database created and migrations applied.")

#     # Now, run the server
#     with contextlib.redirect_stdout(io.StringIO()):
#         execute_from_command_line(['manage.py', 'runserver', '0.0.0.0:8000', '--noreload'])



# #pyinstaller --name DSEC_Local_Server run_server.py
# #pyinstaller DSEC_Local_Server.spec



# import os
# import sys
# import io
# import contextlib
# import subprocess
# import time
# import logging
# from django.conf import settings

# # Configure basic logging to see output from all processes
# logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
# logger = logging.getLogger(__name__)

# # Set the Django settings module
# os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backend.settings")

# # Get the path to the current file
# current_dir = os.path.dirname(os.path.abspath(__file__))

# def check_and_run_migrations():
#     """Checks for the database and runs migrations if it doesn't exist."""
#     db_path = os.path.join(current_dir, 'db.sqlite3')
    
#     # Check for the database file
#     if not os.path.exists(db_path):
#         logger.info("Database file not found. Running migrations...")
        
#         # Use contextlib to suppress excessive command line output
#         with contextlib.redirect_stdout(io.StringIO()):
#             try:
#                 from django.core.management import execute_from_command_line
#                 execute_from_command_line(['manage.py', 'migrate'])
#                 logger.info("Database created and migrations applied.")
#             except Exception as e:
#                 logger.error(f"Failed to run migrations: {e}")
#                 sys.exit(1)

# def run_celery_worker():
#     """Starts the Celery worker in a new process."""
#     logger.info("Starting Celery Worker...")
#     try:
#         # We redirect stdout to a PIPE to capture and log output later
#         worker_process = subprocess.Popen(
#             [sys.executable, '-m', 'celery', '-A', 'backend', 'worker', '--loglevel=info'],
#             cwd=current_dir,
#             stdout=subprocess.PIPE,
#             stderr=subprocess.STDOUT
#         )
#         return worker_process
#     except Exception as e:
#         logger.error(f"Failed to start Celery Worker: {e}")
#         return None

# def run_celery_beat():
#     """Starts the Celery Beat scheduler in a new process."""
#     logger.info("Starting Celery Beat Scheduler...")
#     try:
#         beat_process = subprocess.Popen(
#             [sys.executable, '-m', 'celery', '-A', 'backend', 'beat', '--loglevel=info'],
#             cwd=current_dir,
#             stdout=subprocess.PIPE,
#             stderr=subprocess.STDOUT
#         )
#         return beat_process
#     except Exception as e:
#         logger.error(f"Failed to start Celery Beat: {e}")
#         return None

# if __name__ == "__main__":
#     # Ensure Django is initialized before running other commands
#     try:
#         import django
#         django.setup()
#     except Exception as e:
#         logger.error(f"Django initialization failed: {e}")
#         sys.exit(1)
        
#     # Step 1: Check for and run migrations
#     check_and_run_migrations()
    
#     # Step 2: Start Celery worker and beat in the background
#     worker = run_celery_worker()
#     beat = run_celery_beat()

#     # Give Celery processes a moment to start up
#     time.sleep(5)
    
#     # Step 3: Run the Django server. This is a blocking command.
#     logger.info("Starting Django Server...")
#     try:
#         from django.core.management import execute_from_command_line
#         execute_from_command_line(['manage.py', 'runserver', '0.0.0.0:8000', '--noreload'])
#     except Exception as e:
#         logger.error(f"Django server failed: {e}")
#     finally:
#         # Terminate Celery processes when the Django server stops
#         if worker and worker.poll() is None:
#             worker.terminate()
#         if beat and beat.poll() is None:
#             beat.terminate()

# # Example PyInstaller commands:
# # pyinstaller --name DSEC_Local_Server run_local_server.py
# # pyinstaller DSEC_Local_Server.spec






# # run_server.py (Updated Version)

# import os
# import sys
# import subprocess
# import time
# import logging
# from django.conf import settings
# import io
# import contextlib

# # --- NEW IMPORTS ---
# from waitress import serve
# from django.core.wsgi import get_wsgi_application

# # Configure basic logging
# logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
# logger = logging.getLogger(__name__)

# # Set the Django settings module
# os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backend.settings")

# # Get the path to the current file
# current_dir = os.path.dirname(os.path.abspath(__file__))

# def check_and_run_migrations():
#     """Checks for the database and runs migrations if it doesn't exist."""
#     db_path = os.path.join(settings.BASE_DIR, 'db.sqlite3')
    
#     if not os.path.exists(db_path):
#         logger.info("Database file not found. Running migrations...")
#         with contextlib.redirect_stdout(io.StringIO()):
#             try:
#                 from django.core.management import execute_from_command_line
#                 execute_from_command_line(['manage.py', 'migrate'])
#                 logger.info("Database created and migrations applied.")
#             except Exception as e:
#                 logger.error(f"Failed to run migrations: {e}")
#                 sys.exit(1)

# def run_celery_worker():
#     """Starts the Celery worker in a new process."""
#     logger.info("Starting Celery Worker...")
    
#     command = [sys.executable, '-m', 'celery', '-A', 'backend', 'worker', '--loglevel=info']
    
#     if sys.platform == "win32":
#         command.append('--pool=solo')
        
#     try:
#         worker_process = subprocess.Popen(
#             command,
#             cwd=current_dir,
#             stdout=sys.stdout,
#             stderr=sys.stderr
#         )
#         return worker_process
#     except Exception as e:
#         logger.error(f"Failed to start Celery Worker: {e}")
#         return None

# def run_celery_beat():
#     """Starts the Celery Beat scheduler in a new process."""
#     logger.info("Starting Celery Beat Scheduler...")
    
#     command = [sys.executable, '-m', 'celery', '-A', 'backend', 'beat', '--loglevel=info', '-S', 'django']

#     try:
#         beat_process = subprocess.Popen(
#             command,
#             cwd=current_dir,
#             stdout=sys.stdout,
#             stderr=sys.stderr
#         )
#         return beat_process
#     except Exception as e:
#         logger.error(f"Failed to start Celery Beat: {e}")
#         return None

# # --- REWRITTEN FUNCTION ---
# def run_production_server():
#     """Starts a production-grade Waitress server directly in this process."""
#     logger.info("Starting Waitress Production Server on http://0.0.0.0:8000...")
#     try:
#         # Get the Django WSGI application object
#         application = get_wsgi_application()
#         # This is a blocking call that runs the server in the current process
#         serve(application, host='0.0.0.0', port=8000)
#     except Exception as e:
#         logger.error(f"Waitress server failed: {e}")

# if __name__ == "__main__":
#     try:
#         import django
#         django.setup()
#     except Exception as e:
#         logger.error(f"Django initialization failed: {e}")
#         sys.exit(1)
        
#     check_and_run_migrations()
    
#     worker = run_celery_worker()
#     beat = run_celery_beat()

#     if not worker or not beat:
#         logger.error("Could not start Celery services. Exiting.")
#         if worker: worker.terminate()
#         if beat: beat.terminate()
#         sys.exit(1)

#     time.sleep(5)
    
#     try:
#         run_production_server()
#     except KeyboardInterrupt:
#         logger.info("Shutdown signal received.")
#     finally:
#         logger.info("Terminating background processes...")
#         if worker and worker.poll() is None:
#             worker.terminate()
#             worker.wait()
#         if beat and beat.poll() is None:
#             beat.terminate()
#             beat.wait()
#         logger.info("Shutdown complete.")




# run_server.py (Final Version for PyInstaller)

# import os
# import sys
# import subprocess
# import time
# import logging
# import contextlib
# import io
# import multiprocessing  # <-- Required for PyInstaller

# from waitress import serve
# from django.core.wsgi import get_wsgi_application
# from django.conf import settings

# logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
# logger = logging.getLogger(__name__)

# os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backend.settings")
# current_dir = os.path.dirname(os.path.abspath(__file__))

# def check_and_run_migrations():
#     db_path = os.path.join(settings.BASE_DIR, 'db.sqlite3')
#     if not os.path.exists(db_path):
#         logger.info("Database file not found. Running migrations...")
#         with contextlib.redirect_stdout(io.StringIO()):
#             try:
#                 from django.core.management import execute_from_command_line
#                 execute_from_command_line(['manage.py', 'migrate'])
#                 logger.info("Database created and migrations applied.")
#             except Exception as e:
#                 logger.error(f"Failed to run migrations: {e}")
#                 sys.exit(1)

# def run_celery_worker():
#     logger.info("Starting Celery Worker...")
#     command = [sys.executable, '-m', 'celery', '-A', 'backend', 'worker', '--loglevel=info', '--pool=solo']
#     try:
#         return subprocess.Popen(command, cwd=current_dir, stdout=sys.stdout, stderr=sys.stderr)
#     except Exception as e:
#         logger.error(f"Failed to start Celery Worker: {e}")
#         return None

# def run_celery_beat():
#     logger.info("Starting Celery Beat Scheduler...")
#     command = [sys.executable, '-m', 'celery', '-A', 'backend', 'beat', '--loglevel=info', '-S', 'django']
#     try:
#         return subprocess.Popen(command, cwd=current_dir, stdout=sys.stdout, stderr=sys.stderr)
#     except Exception as e:
#         logger.error(f"Failed to start Celery Beat: {e}")
#         return None

# def run_production_server():
#     logger.info("Starting Waitress Production Server on http://0.0.0.0:8000...")
#     try:
#         application = get_wsgi_application()
#         serve(application, host='0.0.0.0', port=8000)
#     except Exception as e:
#         logger.error(f"Waitress server failed: {e}")

# if __name__ == "__main__":
#     multiprocessing.freeze_support() # <-- MUST be the first line

#     try:
#         import django
#         django.setup()
#     except Exception as e:
#         logger.error(f"Django initialization failed: {e}")
#         sys.exit(1)

#     check_and_run_migrations()
#     worker = run_celery_worker()
#     beat = run_celery_beat()

#     if not worker or not beat:
#         logger.error("Could not start Celery services. Exiting.")
#         if worker: worker.terminate()
#         if beat: beat.terminate()
#         sys.exit(1)

#     time.sleep(5)
    
#     try:
#         run_production_server()
#     except KeyboardInterrupt:
#         logger.info("Shutdown signal received.")
#     finally:
#         logger.info("Terminating background processes...")
#         if worker and worker.poll() is None:
#             worker.terminate()
#             worker.wait()
#         if beat and beat.poll() is None:
#             beat.terminate()
#             beat.wait()
#         logger.info("Shutdown complete.")


# run_server.py (Simplified Final Version)

import os
import sys
import logging
import multiprocessing
import django
from waitress import serve
from django.core.wsgi import get_wsgi_application
from django.conf import settings

# Setup Django before anything else
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backend.settings")
django.setup()

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def check_and_run_migrations():
    db_path = os.path.join(settings.BASE_DIR, 'db.sqlite3')
    if not os.path.exists(db_path):
        logger.info("Database file not found. Running migrations...")
        from django.core.management import execute_from_command_line
        try:
            execute_from_command_line(['manage.py', 'migrate'])
            logger.info("Database created and migrations applied.")
        except Exception as e:
            logger.error(f"Failed to run migrations: {e}")
            sys.exit(1)

def run_production_server():
    logger.info("Starting Waitress Production Server on http://0.0.0.0:8000...")
    try:
        application = get_wsgi_application()
        serve(application, host='0.0.0.0', port=8000)
    except Exception as e:
        logger.error(f"Waitress server failed: {e}")

# --- Main execution block ---
if __name__ == "__main__":
    multiprocessing.freeze_support()

    check_and_run_migrations()
    
    try:
        # The scheduler now starts automatically thanks to api/apps.py
        run_production_server() 
    except KeyboardInterrupt:
        logger.info("Shutdown signal received. Exiting.")
    finally:
        logger.info("Shutdown complete.")