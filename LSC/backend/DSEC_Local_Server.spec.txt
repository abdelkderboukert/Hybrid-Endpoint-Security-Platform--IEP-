# -*- mode: python ; coding: utf-8 -*-

block_cipher = None


a = Analysis(
    ['run_server.py'],
    pathex=['C:\\Users\\HP\\rebo\\3LayersUntiVirus\\LSC\\backend'],
    binaries=[],
    datas=[
    ('db.sqlite3', '.'),
    # Add DRF templates
    ('C:\\Users\\HP\\rebo\\3LayersUntiVirus\\LSC\\backend\\virt\\Lib\\site-packages\\rest_framework\\templates', 'rest_framework\\templates'),
    # Add DRF static files
    ('C:\\Users\\HP\\rebo\\3LayersUntiVirus\\LSC\\backend\\virt\\Lib\\site-packages\\rest_framework\\static', 'rest_framework\\static'),
    ],
    hiddenimports=[
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
        'rest_framework_simplejwt.token_blacklist', # For logout
        'corsheaders',
        'api',

        'celery',
        'celery.app',
        'celery.fixups',
        'celery.fixups.django', 
        'celery.loaders',
        'celery.loaders.app',
        'celery.backends',
        'celery.backends.database',
        'celery.backends.rpc',
        'celery.utils',
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
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='DSEC_Local_Server',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)


coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='DSEC_Local_Server',
    destdir=r'C:\Users\HP\rebo\3LayersUntiVirus\LSC\frontend\assets\backend'
)
