from django.contrib import admin
from django.urls import include, path
from rest_framework import routers
from core import views

router = routers.DefaultRouter()
router.register(r"users", views.UserViewSet)

# Wire up our API using automatic URL routing.
# Additionally, we include login URLs for the browsable API.

urlpatterns = [path("", views.index)]
