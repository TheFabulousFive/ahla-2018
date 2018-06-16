from django.shortcuts import render, redirect
from django.http import HttpResponse
from core.models import User
from django.contrib.auth import login as _login, authenticate


def index(request):
    user = request.user
    return render(request, 'user_index.html', {'user': user})


def login(request):
    return render(request, 'user_login.html')


def do_login(request):
    try:
        from pprint import pprint
        post = request.POST
        pprint(post )
        username = post.get('username', None)
        password = post.get('password', None)
        assert username and password, "Username and password must be provided."
        assert User.objects.filter(username=username).exists(), "Incorrect username or password."
        user = User.objects.get(username=username)
        if user:
            auth_user = authenticate(username=user.username, password=password)
            if auth_user.is_authenticated():
                _login(request, auth_user)
                return redirect('user:index')

    except AssertionError as e:
        return HttpResponse(str(e))

