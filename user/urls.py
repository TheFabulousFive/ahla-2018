from django.conf.urls import url
from .views import index, login, do_login

urlpatterns = [
    url(r'^login/', login, name='login'),
    url(r'^login-do/', do_login, name='do_login'),
    url(r'^', index, name='index'),
]