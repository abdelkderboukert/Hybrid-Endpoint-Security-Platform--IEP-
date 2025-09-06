from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from .models import Server

class LscApiKeyAuthentication(BaseAuthentication):
    """
    Authenticates an LSC server based on its unique API key for service-to-service communication.
    """
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return None

        # Do not handle long JWTs, only short API keys
        key = auth_header.split(' ')[1]
        if len(key) > 40: 
            return None

        try:
            # Find the server that owns this key
            server = Server.objects.select_related('owner_admin').get(api_key=key)
            
            # The admin that owns this server is the authenticated user for this request
            admin = server.owner_admin 
            if not admin:
                raise AuthenticationFailed('API key is valid, but the server is not associated with an admin.')
            
            return (admin, None) # Authentication successful
        except Server.DoesNotExist:
            raise AuthenticationFailed('Invalid API Key.')
        except Exception:
            raise AuthenticationFailed('An unknown authentication error occurred.')