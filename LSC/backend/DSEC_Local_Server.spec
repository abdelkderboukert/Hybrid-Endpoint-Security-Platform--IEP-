# -*- mode: python ; coding: utf-8 -*-

from PyInstaller.utils.hooks import collect_data_files

block_cipher = None

# Collect all of Django's required data files (like templates, translations)
django_datas = collect_data_files('django')

a = Analysis(
    ['run_server.py'],
    pathex=['C:\\Users\\HP\\rebo\\3LayersUntiVirus\\LSC\\backend'],
    binaries=[],
    datas=[
        # Manually include the Django REST Framework templates
        ('C:\\Users\\HP\\rebo\\3LayersUntiVirus\\LSC\\backend\\virt\\Lib\\site-packages\\rest_framework\\templates', 'rest_framework/templates'),
        *django_datas,
    ],
    hiddenimports=[
        # Your Django apps and libraries from INSTALLED_APPS
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
        
        # ✅ NEW: APScheduler and its dependencies
        'django_apscheduler',
        'apscheduler',
        'apscheduler.schedulers.background',
        'apscheduler.executors.pool',
        'atexit',

        # Other critical packages used by your project
        'psutil',
        'waitress',
        'decouple',
        
        # pywin32 modules used in util.py
        'win32api',
        'win32con',
        'win32file',
        'win32security', # Added for domain info detection
    ],
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
    console=True, # Important for seeing server logs
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