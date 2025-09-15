# api/management/commands/seed_db.py

import random
from faker import Faker
from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone
import uuid

# Import all your models
from api.models import (
    Admin, Server, Device, User, Group, LicenseKey, BootstrapToken
)

# --- Configuration ---
NUM_LOCAL_ADMINS = 3
DEVICES_PER_SERVER = 5
USERS_PER_ADMIN = 10
GROUPS_PER_ADMIN = 3
DEFAULT_PASSWORD = "password123"


class Command(BaseCommand):
    help = 'Seeds the database with a realistic hierarchy of fake data for testing.'

    @transaction.atomic
    def handle(self, *args, **kwargs):
        self.stdout.write(self.style.SUCCESS('--- Starting Database Seeding ---'))

        # 0. Clean up existing data
        self.stdout.write('Clearing existing data...')
        Device.objects.all().delete()
        User.objects.all().delete()
        Group.objects.all().delete()
        Server.objects.all().delete()
        BootstrapToken.objects.all().delete()
        Admin.objects.all().delete()
        LicenseKey.objects.all().delete()
        self.stdout.write(self.style.SUCCESS('Data cleared.'))

        # Instantiate Faker
        faker = Faker()

        # 1. Create the master License Key
        self.stdout.write('Creating License Key...')
        license_key = LicenseKey.objects.create(
            key=str(uuid.uuid4()).upper(),
            is_active=True,
        )
        self.stdout.write(self.style.SUCCESS(f'License Key created: {license_key.key}'))

        # 2. Create the top-level Cloud Admin (Layer 0)
        self.stdout.write('Creating Cloud Admin (Layer 0)...')
        cloud_admin = Admin.objects.create_superuser(
            username='cloud_admin',
            email='cloud_admin@example.com',
            password=DEFAULT_PASSWORD,
            layer=0,
            license=license_key
        )
        license_key.assigned_admin = cloud_admin
        license_key.save()
        self.stdout.write(self.style.SUCCESS('Cloud Admin created.'))
        
        # 3. Create the top-level Cloud Server
        self.stdout.write('Creating Cloud Server...')
        cloud_server = Server.objects.create(
            server_type='Cloud',
            is_connected=True,
            last_heartbeat=timezone.now(),
            server_name='Main Cloud Server',
            hostname='cloud.main.local',
            ip_address=faker.ipv4(),
            mac_address=faker.mac_address(),
            owner_admin=cloud_admin,
            auto_detected=False
        )
        cloud_admin.server = cloud_server
        cloud_admin.save()
        self.stdout.write(self.style.SUCCESS('Cloud Server created.'))

        local_admins = []
        local_servers = []

        # 4. Create Local Admins (Layer 1) and their corresponding Local Servers
        self.stdout.write(f'Creating {NUM_LOCAL_ADMINS} Local Admins and Servers...')
        for i in range(NUM_LOCAL_ADMINS):
            hostname = f'lsc-zone-{i+1}'
            # Create Local Admin
            local_admin = Admin.objects.create_user(
                username=f'local_admin_{i+1}',
                email=f'local_admin_{i+1}@example.com',
                password=DEFAULT_PASSWORD,
                layer=1,
                parent_admin_id=cloud_admin,
                license=license_key
            )
            local_admins.append(local_admin)

            # Create corresponding Local Server
            local_server = Server.objects.create(
                server_type='Local',
                parent_server=cloud_server,
                is_connected=random.choice([True, False]),
                last_heartbeat=timezone.now() - timezone.timedelta(minutes=random.randint(1, 60)),
                server_name=f'Zone {i+1} Server',
                hostname=hostname,
                domain='corp.local',
                ip_address=faker.ipv4(),
                mac_address=faker.mac_address(),
                system_uuid=uuid.uuid4(),
                owner_admin=local_admin,
                auto_detected=True
            )
            local_servers.append(local_server)
            
            # Link the admin to their server
            local_admin.server = local_server
            local_admin.save()

        self.stdout.write(self.style.SUCCESS(f'{NUM_LOCAL_ADMINS} Local Admins and Servers created.'))

        # 5. Create Devices for each Local Server
        self.stdout.write(f'Creating {DEVICES_PER_SERVER} devices for each local server...')
        for server in local_servers:
            for _ in range(DEVICES_PER_SERVER):
                device_type = random.choice(['Desktop', 'Laptop'])
                Device.objects.create(
                    device_name=f"{device_type}-{faker.word().capitalize()}",
                    os=random.choice(['Windows 11', 'Windows 10', 'macOS Sonoma']),
                    server=server,
                    is_isolated=random.choice([True, False]),
                    device_type=device_type,
                    manufacturer=random.choice(['Dell', 'HP', 'Lenovo', 'Apple']),
                    processor='Intel Core i7',
                    ram_gb=random.choice([8, 16, 32]),
                    ip_addresses=[faker.ipv4()],
                    mac_addresses=[faker.mac_address()]
                )
        self.stdout.write(self.style.SUCCESS('Devices created.'))

        # 6. Create Users and Groups under each Local Admin
        self.stdout.write('Creating Users and Groups...')
        all_groups = []
        for admin in local_admins:
            groups_for_admin = []
            # Create Groups
            for i in range(GROUPS_PER_ADMIN):
                group = Group.objects.create(
                    group_name=f'{admin.username}_group_{i+1}',
                    parent_admin_id=admin,
                    license=license_key,
                    description=faker.sentence()
                )
                groups_for_admin.append(group)
                all_groups.append(group)
            
            # Create Users
            for _ in range(USERS_PER_ADMIN):
                user = User.objects.create(
                    username=faker.user_name(),
                    email=faker.email(),
                    parent_admin_id=admin,
                    license=license_key
                )
                # Assign user to 1 or 2 random groups from this admin
                num_groups = random.randint(1, 2)
                assigned_groups = random.sample(groups_for_admin, num_groups)
                user.groups.set(assigned_groups)
        self.stdout.write(self.style.SUCCESS('Users and Groups created and associated.'))

        # 7. Create a Bootstrap Token
        self.stdout.write('Creating a Bootstrap Token...')
        BootstrapToken.objects.create(
            created_by=cloud_admin,
            is_used=False
        )
        self.stdout.write(self.style.SUCCESS('Bootstrap Token created.'))

        self.stdout.write(self.style.SUCCESS('--- Database Seeding Completed Successfully! ---'))
        self.stdout.write(f'Default password for all users is: {DEFAULT_PASSWORD}')