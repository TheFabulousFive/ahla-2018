from django.shortcuts import render, redirect, reverse
from django.http import HttpResponse, JsonResponse
from core.models import User, Conversation, Message
from django.contrib.auth import login as _login, authenticate
from django.db.models import Q


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
                'url': reverse('user:join_conversation', kwargs={'conversation_id': conversation.pk})
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
    try:

        user = request.user
        conversation = Conversation.objects.get(pk=conversation_id)
        assert str(user.pk) in [str(conversation.patient.pk), str(conversation.professional.pk)], \
            "You are not part of this conversation"

        return render(request, 'user_conversation.html', {'conversation': conversation})

    except AssertionError as e:
        import traceback
        traceback.print_exc()
        return HttpResponse(str(e))

    except Exception as e:
        import traceback
        traceback.print_exc()
        return HttpResponse(str(e))


def user_messages(request):
    user = request.user

    if user.is_patient():
        conversations = Conversation.objects.filter(Q(patient=user) | Q(professional=user)).all()
    else:
        conversations = Conversation.objects.filter(Q(professional=user) | Q(status='pending')).all()

    return render(request, 'user_messages.html', {'conversations': conversations})


def join_conversation(request, conversation_id):
    try:

        user = request.user
        conversation = Conversation.objects.get(pk=conversation_id)
        if str(conversation.patient.pk) != str(user.pk):
            assert user.is_professional(), "You must be a validated professional."
        assert conversation.status not in ['closed', 'suspended'], "Conversation is not available"
        conversation.professional = user
        conversation.save()
        conversation.activate()
        return redirect(reverse('user:serve_conversation', kwargs={'conversation_id': conversation.pk}))

    except AssertionError as e:
        import traceback
        traceback.print_exc()
        return HttpResponse(str(e))

    except Exception as e:
        import traceback
        traceback.print_exc()
        return HttpResponse(str(e))


def get_conversation_messages(request, conversation_id):
    try:
        user = request.user
        conversation = Conversation.objects.get(pk=conversation_id)
        assert str(user.pk) in [str(conversation.patient.pk), str(conversation.professional.pk)], \
            "You are not part of this conversation"

        messages = [{
            'id': message.pk.__str__(),
            'text': message.text,
            'username': message.user.username if message.user.is_professional() else conversation.patient_penname,
            'created_at': message.created_at.timestamp(),
            'is_patient': message.user.is_patient()
        } for message in conversation.message_set.all()]

        return JsonResponse({
            'status': True,
            'data': {
                'id': conversation.pk.__str__(),
                'title': conversation.title,
                'tags': conversation.tags,
                'messages': messages
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


def get_message(request, message_id):
    try:
        user = request.user
        message = Message.objects.get(pk=message_id)
        conversation = message.conversation
        assert str(user.pk) in [str(conversation.patient.pk), str(conversation.professional.pk)], \
            "You are not part of this conversation"

        return JsonResponse({
            'status': True,
            'data': {
                'id': message.pk.__str__(),
                'text': message.text,
                'username': message.user.username if message.user.is_professional() else conversation.patient_penname,
                'created_at': message.created_at.timestamp(),
                'is_patient': message.user.is_patient()
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


def create_message(request, conversation_id):
    try:
        user = request.user
        conversation = Conversation.objects.get(pk=conversation_id)
        assert str(user.pk) in [str(conversation.patient.pk), str(conversation.professional.pk)], \
            "You are not part of this conversation"

        post = request.POST
        text = post.get('text')
        assert text, 'Empty message'
        message = Message.objects.create(
            conversation=conversation,
            user=user,
            text=text
        )

        return JsonResponse({
            'status': True,
            'data': {
                'id': message.pk.__str__(),
                'text': message.text,
                'username': message.user.username if message.user.is_professional() else conversation.patient_penname,
                'created_at': message.created_at.timestamp(),
                'is_patient': message.user.is_patient()
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
