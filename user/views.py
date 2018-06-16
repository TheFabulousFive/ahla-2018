from django.shortcuts import render, redirect, reverse
from django.http import HttpResponse, JsonResponse
from core.models import User, Conversation
from django.contrib.auth import login as _login, authenticate



def index(request):
    user = request.user
    return render(request, 'user_index.html', {'user': user})


def login(request):
    return render(request, 'user_login.html')


def do_login(request):
    try:
        post = request.POST
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


def create_conversation(request):
    try:
        post = request.POST
        user = request.user
        title = post.get('title', None)
        tags = post.get('tags', None)

        assert title and tags, "Please provide a title and tags for this conversation."
        tags = ', '.join(tags.split(' '))
        patient = None
        professional = None
        if user.is_patient():
            patient = user
        conversation = Conversation.objects.create(
            title=title,
            patient=patient,
            professional=professional,
            tags=tags
        )
        return JsonResponse({
            'status': True,
            'data': {
                'id': conversation.pk.__str__(),
                'url': reverse('user:serve_conversation', kwargs={'conversation_id': conversation.pk})
            },
            'error': None
        })

    except AssertionError as e:
        return JsonResponse({
            'status': False,
            'error': str(e)
        })

    except Exception as e:
        return JsonResponse({
            'status': False,
            'error': str(e)
        })


def serve_conversation(request, conversation_id):
    return HttpResponse('Hello %s' % conversation_id)
