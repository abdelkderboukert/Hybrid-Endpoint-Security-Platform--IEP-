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



import os
import sys
import io
import contextlib
import subprocess
import time
import logging

# Configure basic logging to see output from all processes
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Set the Django settings module
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backend.settings")

# Get the path to the current file
current_dir = os.path.dirname(os.path.abspath(__file__))

def check_and_run_migrations():
    """Checks for the database and runs migrations if it doesn't exist."""
    db_path = os.path.join(current_dir, 'db.sqlite3')
    
    # Check for the database file
    if not os.path.exists(db_path):
        logger.info("Database file not found. Running migrations...")
        
        # Use contextlib to suppress excessive command line output
        with contextlib.redirect_stdout(io.StringIO()):
            try:
                from django.core.management import execute_from_command_line
                execute_from_command_line(['manage.py', 'migrate'])
                logger.info("Database created and migrations applied.")
            except Exception as e:
                logger.error(f"Failed to run migrations: {e}")
                sys.exit(1)

def run_celery_worker():
    """Starts the Celery worker in a new process."""
    logger.info("Starting Celery Worker...")
    try:
        # We redirect stdout to a PIPE to capture and log output later
        worker_process = subprocess.Popen(
            [sys.executable, '-m', 'celery', '-A', 'backend', 'worker', '--loglevel=info'],
            cwd=current_dir,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT
        )
        return worker_process
    except Exception as e:
        logger.error(f"Failed to start Celery Worker: {e}")
        return None

def run_celery_beat():
    """Starts the Celery Beat scheduler in a new process."""
    logger.info("Starting Celery Beat Scheduler...")
    try:
        beat_process = subprocess.Popen(
            [sys.executable, '-m', 'celery', '-A', 'backend', 'beat', '--loglevel=info'],
            cwd=current_dir,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT
        )
        return beat_process
    except Exception as e:
        logger.error(f"Failed to start Celery Beat: {e}")
        return None

if __name__ == "__main__":
    # Ensure Django is initialized before running other commands
    try:
        import django
        django.setup()
    except Exception as e:
        logger.error(f"Django initialization failed: {e}")
        sys.exit(1)
        
    # Step 1: Check for and run migrations
    check_and_run_migrations()
    
    # Step 2: Start Celery worker and beat in the background
    worker = run_celery_worker()
    beat = run_celery_beat()

    # Give Celery processes a moment to start up
    time.sleep(5)
    
    # Step 3: Run the Django server. This is a blocking command.
    logger.info("Starting Django Server...")
    try:
        from django.core.management import execute_from_command_line
        execute_from_command_line(['manage.py', 'runserver', '0.0.0.0:8000', '--noreload'])
    except Exception as e:
        logger.error(f"Django server failed: {e}")
    finally:
        # Terminate Celery processes when the Django server stops
        if worker and worker.poll() is None:
            worker.terminate()
        if beat and beat.poll() is None:
            beat.terminate()

# Example PyInstaller commands:
# pyinstaller --name DSEC_Local_Server run_local_server.py
# pyinstaller DSEC_Local_Server.spec