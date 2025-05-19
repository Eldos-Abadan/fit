from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework.exceptions import AuthenticationFailed
from django.utils.deprecation import MiddlewareMixin

class JWTAuthenticationMiddleware(MiddlewareMixin):
    def process_request(self, request):
        auth_header = request.META.get('HTTP_AUTHORIZATION', '')
        
        if not auth_header:
            return None
        
        try:
            auth = JWTAuthentication()
            validated_token = auth.get_validated_token(auth_header.split()[1])
            user = auth.get_user(validated_token)
            request.user = user
        except (IndexError, AuthenticationFailed):
            return None