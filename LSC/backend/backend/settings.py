from pathlib import Path
from decouple import config
from datetime import timedelta
import os
from dotenv import load_dotenv

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/5.2/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'django-insecure-(7x7n+k(&gxn6)_jt624i&u0#i1-5-9o3$*1b3u-q^_6rmlfk*'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True


ALLOWED_HOSTS = ['*']


# Application definition

INSTALLED_APPS = [
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
    'django_apscheduler',
    
]

# Tell Django to use your custom Admin model for authentication
AUTH_USER_MODEL = 'api.Admin'

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    # 'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',  # CORS middleware
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'backend.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'backend.wsgi.application'


# Database
# https://docs.djangoproject.com/en/5.2/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
        'TIMEOUT': 20,
    }
}

# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.postgresql',
#         'NAME': config('DB_NAME'),
#         'USER': config('DB_USER'),
#         'PASSWORD': config('DB_PASSWORD'),
#         'HOST': config('DB_HOST'),
#         'PORT': config('DB_PORT'),
#     }
# }



# Password validation
# https://docs.djangoproject.com/en/5.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/5.2/topics/i1n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.2/howto/static-files/

STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

# Add this list to tell Django where to look for your project-level static files
STATICFILES_DIRS = [
    BASE_DIR / "static",
]

# Default primary key field type
# https://docs.djangoproject.com/en/5.2/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'


# --- CORS Configuration ---
# Allow your Next.js frontend to make requests to the Django API
# CORS_ALLOWED_ORIGINS = [
#     "http://localhost:3000",
# ]
# To send cookies from the frontend
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_ALL_ORIGINS = True

# --- Django REST Framework Configuration ---
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
        'api.authentication.LscApiKeyAuthentication', # For LSC-to-LSC communication
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'api.renderers.CustomJSONRenderer', # Handles UUID serialization
    ],
}


# --- Simple JWT Configuration ---
from datetime import timedelta

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=25), # Short lifetime for access token
    'REFRESH_TOKEN_LIFETIME': timedelta(days=1),  # Longer lifetime for refresh token
    'ROTATE_REFRESH_TOKENS': True, # A new refresh token is issued when you use a refresh token
    'BLACKLIST_AFTER_ROTATION': True, # Blacklists the old refresh token
    'UPDATE_LAST_LOGIN': True,

    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'VERIFYING_KEY': None,
    'AUDIENCE': None,
    'ISSUER': None,
    'JWK_URL': None,
    'LEEWAY': 0,

    'AUTH_HEADER_TYPES': ('Bearer',),
    'AUTH_HEADER_NAME': 'HTTP_AUTHORIZATION',
    'USER_ID_FIELD': 'admin_id',
    'USER_ID_CLAIM': 'user_id',
    'USER_AUTHENTICATION_RULE': 'rest_framework_simplejwt.authentication.default_user_authentication_rule',

    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'TOKEN_TYPE_CLAIM': 'token_type',
    'TOKEN_USER_CLASS': 'rest_framework_simplejwt.models.TokenUser',

    'JTI_CLAIM': 'jti',

    'SLIDING_TOKEN_REFRESH_EXP_CLAIM': 'refresh_exp',
    'SLIDING_TOKEN_LIFETIME': timedelta(minutes=25),
    'SLIDING_TOKEN_REFRESH_LIFETIME': timedelta(days=1),

    # Custom settings to deliver tokens via HttpOnly cookies
    'AUTH_COOKIE': 'access_token',  # Cookie name for access token
    'AUTH_COOKIE_REFRESH': 'refresh_token', # Cookie name for refresh token
    'AUTH_COOKIE_DOMAIN': None,
    'AUTH_COOKIE_SECURE': False, # Set to True in production (HTTPS)
    'AUTH_COOKIE_HTTP_ONLY' : True, # Essential for security
    'AUTH_COOKIE_PATH': '/',
    'AUTH_COOKIE_SAMESITE': 'Lax', # Or 'Strict'
}


REST_AUTH = {
    'USE_JWT': True,
    'JWT_AUTH_HTTPONLY': True, # Use HttpOnly cookies
    'JWT_AUTH_COOKIE': 'access_token',
    'JWT_AUTH_REFRESH_COOKIE': 'refresh_token',
}

# CELERY_BROKER_URL = 'redis://localhost:6379/0'
# CELERY_RESULT_BACKEND = 'redis://localhost:6379/0'


# from celery.schedules import crontab

# CELERY_BEAT_SCHEDULE = {
#     'run-master-sync-every-15-minutes': {
#         'task': 'api.tasks.run_master_sync',  # The path to your task function
#         # 'schedule': crontab(minute='*/15'),   # Runs every 15 minutes
#         'schedule': crontab(minute='*/1'),   # Runs every 1 minute (for testing)
#     },
# }



# --- WARNING: This method is not secure and requires the app to run as an administrator ---

# Define the app name exactly as it is in your Inno Setup script
APP_NAME = "Bluck D-ESC"
FOLDER_NAME = f"{APP_NAME}_env"

# Build the path to the root of the C: drive.
# os.environ.get('SystemDrive', 'C:') reliably gets the system drive letter.
system_drive = os.environ.get('SystemDrive', 'C:')
env_path = Path(f"{system_drive}\\") / FOLDER_NAME / '.env'
ENV_PATH = env_path

# Load the .env file if it exists
if env_path.exists():
    load_dotenv(dotenv_path=env_path)
else:
    # Optional: Handle the case where the .env file is missing
    print(f"WARNING: Environment file not found at {env_path}")

# Now you can access your variables
PARENT_SERVER_ID = os.getenv('PARENT_SERVER_ID')
LSC_MAC_ADDRESS = os.getenv('LSC_MAC_ADDRESS')
INITIAL_PARENT_IP = os.getenv('INITIAL_PARENT_IP')
MCC_IP_ADDRESS = os.getenv('MCC_IP_ADDRESS')
BOOTSTRAP_TOKEN = os.getenv('BOOTSTRAP_TOKEN')
LSC_API_KEY = os.getenv('LSC_API_KEY')
OWNER_ADMIN_ID = os.getenv('OWNER_ADMIN_ID')

CORS_ALLOW_ALL_ORIGINS = True