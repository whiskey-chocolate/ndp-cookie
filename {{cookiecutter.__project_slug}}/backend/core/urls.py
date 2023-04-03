from django.urls import include, path
from rest_framework import routers
from core import views

router = routers.DefaultRouter()
router.register(r"users", views.UserViewSet)

urlpatterns = [
    path("", views.index),
    path("", include(router.urls)),
]
