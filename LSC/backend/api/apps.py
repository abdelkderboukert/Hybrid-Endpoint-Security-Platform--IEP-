# api/apps.py

from django.apps import AppConfig

class ApiConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'api'

    def ready(self):
        """
        This method is called once Django is ready.
        We start the scheduler here to ensure it runs in the background.
        """
        # We import here to avoid AppRegistryNotReady errors
        from . import scheduler
        
        # Check a flag to prevent the scheduler from running twice,
        # which can happen with Django's auto-reloader in DEBUG mode.
        import os
        if os.environ.get('RUN_MAIN', None) != 'true':
            scheduler.start()