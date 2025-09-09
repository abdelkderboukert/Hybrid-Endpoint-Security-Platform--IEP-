# -*- mode: python ; coding: utf-8 -*-

from PyInstaller.utils.hooks import collect_data_files

block_cipher = None

# Collect all of Django's required data files (like translations)
django_datas = collect_data_files('django')


a = Analysis(
    ['run_server.py'],
    pathex=['C:\\Users\\HP\\rebo\\3LayersUntiVirus\\LSC\\backend'],
    binaries=[],
    datas=[
        ('C:\\Users\\HP\\rebo\\3LayersUntiVirus\\LSC\\backend\\virt\\Lib\\site-packages\\rest_framework\\templates', 'rest_framework/templates'),
        *django_datas,
    ],
    hiddenimports=[
        # Django apps
        'django.contrib.admin',
        'django.contrib.auth',
        'django.contrib.contenttypes',
        'django.contrib.sessions',
        'django.contrib.messages',
        'django.contrib.staticfiles',
        'rest_framework',
        'rest_framework.authtoken',
        'dj_rest_auth',
        'dj_rest_auth.registration',
        'rest_framework_simplejwt',
        'rest_framework_simplejwt.token_blacklist',
        'corsheaders',
        'api',
        'django_celery_beat',

        # Other critical packages
        'whitenoise',
        'psutil',
        'chardet',
        'dotenv',
        'waitress',
        
        # pywin32 modules
        'win32timezone',
        'win32api',
        'win32con',
        'win32file',

        # The Definitive Celery List
        'celery',
        'celery.app',
        'celery.fixups',
        'celery.fixups.django',
        'celery.loaders',
        'celery.loaders.app',
        'celery.backends',
        'celery.backends.database',
        'celery.backends.rpc',
        'kombu.transport.redis',
        'celery.concurrency.solo',
        'celery.apps.worker',
        'celery.apps.beat',
        'celery.app.log',
        'celery.contrib.django',
        'celery.app.amqp',
        'django_celery_beat.schedulers',
        'celery.worker.components',
        'django_celery_beat.models',
        'celery.worker.autoscale',
        'billiard',
    ],  # <-- A missing comma here can cause the syntax error
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure, a.zipped_data,
          cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='DSEC_Local_Server',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=True,
)
coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    name='DSEC_Local_Server',
)