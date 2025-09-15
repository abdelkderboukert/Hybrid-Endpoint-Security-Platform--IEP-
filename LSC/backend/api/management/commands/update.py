from django.core.management.base import BaseCommand, CommandError
from api.models import *
class Command(BaseCommand):
    # A brief description of the command, which will show up in `python manage.py help`
    help = 'Updates the IP address of a specific server for testing.'

    def handle(self, *args, **options):
        # The specific ID and IP address you want to use
        server_id = 'c5c7e81299eb4f84bb7b963541d65c36'
        new_ip = '192.168.1.116'

        try:
            # 1. Get the object from the database
            server_to_edit = Server.objects.get(server_id=server_id)

            # # 2. Modify the ip_address field
            # server_to_edit.is_used = 0
            # server_to_edit.save()
            server_to_edit.delete()

            # 3. Print a success message to the console
            self.stdout.write(self.style.SUCCESS(
                f"✅ Successfully updated server '{server_id}' to new IP: {new_ip}"
            ))

        except BootstrapToken.DoesNotExist:
            raise CommandError(f"❌ Error: Server with ID '{server_id}' was not found.")
        except Exception as e:
            raise CommandError(f"An unexpected error occurred: {e}")