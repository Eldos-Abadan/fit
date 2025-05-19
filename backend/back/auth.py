from django.conf import settings
from django.contrib.auth import get_user_model
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
import jwt, datetime
from rest_framework_simplejwt.tokens import RefreshToken
from .models import User 

User = get_user_model()

import json
import jwt
import bcrypt
from datetime import datetime, timedelta
from django.http import JsonResponse, HttpResponseBadRequest
from django.views.decorators.csrf import csrf_exempt
from django.utils import timezone
from django.contrib.auth import get_user_model
from django.conf import settings


@csrf_exempt
def login_view(request):
    if request.method != 'POST':
        return HttpResponseBadRequest("Тек POST әдісі қабылданады.")

    # JSON немесе form data оқылуы
    if request.content_type == 'application/json':
        try:
            data = json.loads(request.body)
        except json.JSONDecodeError:
            return JsonResponse({"detail": "Invalid JSON data"}, status=400)
    else:
        data = request.POST

    email = data.get("email")
    password = data.get("password")
    
    if not email or not password:
        return JsonResponse({"detail": "Email және құпиясөз қажет"}, status=400)
    
    User = get_user_model()
    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return JsonResponse({"detail": "Пайдаланушы табылмады"}, status=404)
    
    # Django-ның өз әдісін қолданамыз:
    if not user.check_password(password):
        return JsonResponse({"detail": "Құпиясөз дұрыс емес"}, status=400)
    
    if not user.status:
        return JsonResponse({"detail": "Аккаунт белсенді емес"}, status=403)
    
    # Токен жасау (толық үлгісі жоғарыдағы мысалдарда берілгендей)
    now = datetime.utcnow()
    exp = now + timedelta(seconds=getattr(settings, 'JWT_ACCESS_TOKEN_LIFETIME', 30*60))
    token_payload = {
        "user_id": str(user.id),
        "iat": now.timestamp(),
        "exp": exp.timestamp(),
    }
    token = jwt.encode(token_payload, getattr(settings, 'JWT_SECRET', settings.SECRET_KEY), algorithm="HS256")
    
    user.last_login = timezone.now()
    user.last_active = timezone.now()
    user.save(update_fields=["last_login", "last_active"])
    
    response_data = {
        "token": token,
        "user": {
            "id": str(user.id),
            "email": user.email,
            "full_name": f"{user.first_name} {user.last_name}".strip(),
            "role": user.role,
        }
    }
    
    return JsonResponse(response_data, status=200)


@api_view(['POST'])
@csrf_exempt
@permission_classes([AllowAny])
def refresh_token(request):
    """Refresh JWT Access Token. Expects 'refresh' token in request data."""
    refresh = request.data.get('refresh')
    if not refresh:
        return Response({"data": "Refresh токені қажет!"}, status=status.HTTP_400_BAD_REQUEST)
    jwt_secret = getattr(settings, 'JWT_SECRET', settings.SECRET_KEY)
    try:
        payload = jwt.decode(refresh, jwt_secret, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        return Response({"data": "Refresh токенінің мерзімі өтіп кетті!"}, status=status.HTTP_401_UNAUTHORIZED)
    except jwt.InvalidTokenError:
        return Response({"data": "Қате токен!"}, status=status.HTTP_400_BAD_REQUEST)
    # Ensure this is a refresh token
    if payload.get("token_type") != "refresh":
        return Response({"data": "Refresh токені жарамсыз!"}, status=status.HTTP_400_BAD_REQUEST)
    user_id = payload.get("user_id")
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return Response({"data": "Пайдаланушы табылмады!"}, status=status.HTTP_404_NOT_FOUND)
    # Create new access token
    new_access_payload = {
        "user_id": str(user.id),
        "token_type": "access",
        "exp": datetime.datetime.utcnow() + datetime.timedelta(minutes=30)
    }
    new_access_token = jwt.encode(new_access_payload, jwt_secret, algorithm="HS256")
    data = {
        "access": new_access_token
    }
    return Response({"data": data}, status=status.HTTP_200_OK)
