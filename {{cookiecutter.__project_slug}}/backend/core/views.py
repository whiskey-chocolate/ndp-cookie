from django_filters import rest_framework as filters
from django.http import HttpResponseRedirect
from rest_framework import viewsets, status
from rest_framework.decorators import (
    authentication_classes,
    permission_classes,
    api_view,
)
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response

from core.models import User
from core.serializers import UserSerializer


class UserFilter(filters.FilterSet):
    class Meta:
        model = User
        fields = ["id", "email"]


class UserViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows users to be viewed or edited.
    """

    queryset = User.objects.all().order_by("-date_joined")
    serializer_class = UserSerializer
    filter_backends = (filters.DjangoFilterBackend,)
    filterset_fields = ("id", "email")

    def create(self, request, *args, **kwargs):
        try:
            return super(UserViewSet, self).create(request, *args, **kwargs)
        except ValidationError as err:
            user_id = User.objects.get(email=request.data["email"]).id
            return HttpResponseRedirect(redirect_to=f"/users/{user_id}/")


@api_view((["GET"]))
@authentication_classes([])
@permission_classes([])
def index(request):
    # connection.ensure_connection()
    return Response({"database": "ok"}, status=status.HTTP_200_OK)
