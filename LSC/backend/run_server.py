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