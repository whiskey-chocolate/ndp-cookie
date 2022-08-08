from django.conf import settings
from django.conf import settings
from .models import User
import firebase_admin
from firebase_admin import auth

from rest_framework import authentication

from .exceptions import FirebaseError, InvalidAuthToken, NoAuthToken

creds = firebase_admin.credentials.Certificate(
    settings.CREDENTIALS["FIREBASE_APPLICATION_CREDENTIALS"]
)

firebase_app = firebase_admin.initialize_app(creds)


class FirebaseAuthentication(authentication.BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.META.get("HTTP_AUTHORIZATION")
        if not auth_header:
            raise NoAuthToken("No auth token provided")

        id_token = auth_header.split(" ").pop()
        decoded_token = None
        try:
            decoded_token = auth.verify_id_token(id_token)
        except Exception:
            raise InvalidAuthToken("Invalid auth token")

        if not id_token or not decoded_token:
            return None

        try:
            uid = decoded_token.get("uid")
        except Exception:
            raise FirebaseError()

        firebase_user = auth.get_user(uid=uid)
        user, created = User.objects.get_or_create(email=firebase_user.email)

        return (user, None)
