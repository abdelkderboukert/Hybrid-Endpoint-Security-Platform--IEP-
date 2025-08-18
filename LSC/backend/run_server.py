import os
import sys
import io
import contextlib
from django.core.management import execute_from_command_line

if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backend.settings")

    # Check if the database file exists
    db_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'db.sqlite3')
    if not os.path.exists(db_path):
        print("Database not found. Running migrations...")
        with contextlib.redirect_stdout(io.StringIO()):
            execute_from_command_line(['manage.py', 'migrate'])
        print("Database created and migrations applied.")

    # Now, run the server
    with contextlib.redirect_stdout(io.StringIO()):
        execute_from_command_line(['manage.py', 'runserver', '0.0.0.0:8000', '--noreload'])



#pyinstaller --name DSEC_Local_Server run_server.py
#pyinstaller DSEC_Local_Server.spec