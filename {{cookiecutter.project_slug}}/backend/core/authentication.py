from django.conf import settings
from firebase_admin import auth, credentials, initialize_app
from rest_framework import authentication

from core.models import User
from core.exceptions import FirebaseAuthenticationError, InvalidAuthToken, NoAuthToken

creds = credentials.Certificate(
    settings.CREDENTIALS["FIREBASE_APPLICATION_CREDENTIALS"]
)

firebase_app = initialize_app(creds)


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
            raise FirebaseAuthenticationError()

        firebase_user = auth.get_user(uid=uid)
        user, created = User.objects.get_or_create(email=firebase_user.email)
        request_email = request.data.get("email") or request.query_params.get("email")
        if (request_email is not None) and (request_email != user.email):
            raise FirebaseAuthenticationError("Email does not match token provided")
        request_user_id = (
            request.data.get("user_id")
            or request.query_params.get("user_id")
            or request.data.get("owner_id")
        )
        if (request_user_id is not None) and (request_user_id != str(user.id)):
            raise FirebaseAuthenticationError("Id does not match token provided")

        return (user, None)

