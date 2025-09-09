# api/scheduler.py

from apscheduler.schedulers.background import BackgroundScheduler
from api.tasks import run_master_sync
import logging
import atexit

logger = logging.getLogger(__name__)

def start():
    """
    Starts the background scheduler and adds the sync task.
    """
    scheduler = BackgroundScheduler()
    
    # Schedule run_master_sync to run every 1 minute for testing.
    # For production, change minute='*/1' to minute='*/15'
    scheduler.add_job(
        run_master_sync, 
        'cron', 
        minute='*/1', 
        id='run_master_sync_job', 
        replace_existing=True
    )
    
    # atexit hook ensures that the scheduler shuts down gracefully
    atexit.register(lambda: scheduler.shutdown())
    
    scheduler.start()
    logger.info("✅ APScheduler has been started and the sync job is scheduled.")