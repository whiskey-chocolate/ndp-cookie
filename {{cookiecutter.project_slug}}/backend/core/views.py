from rest_framework import viewsets
from core.models import User
from core.serializers import UserSerializer
from django.conf import settings
from django.http import JsonResponse
from rest_framework.decorators import authentication_classes, permission_classes

# Create your views here.
class UserViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows users to be viewed or edited.
    """

    queryset = User.objects.all().order_by("-date_joined")
    serializer_class = UserSerializer


@authentication_classes([])
@permission_classes([])
def index(request):
    return JsonResponse({"message": "System up."})
