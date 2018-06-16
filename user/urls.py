from django.conf.urls import url
from .views import (
    index,
    login,
    do_login,
    create_conversation,
    serve_conversation,
    user_messages,
    join_conversation,
    get_conversation_messages,
    get_message,
    create_message
)

urlpatterns = [
    url(r'^login/', login, name='login'),
    url(r'^login-do/', do_login, name='do_login'),
    url(r'^messages/join/(?P<conversation_id>[^/]+)/', join_conversation, name='join_conversation'),
    url(r'^messages/', user_messages, name='messages'),
    url(r'^create-conversation/', create_conversation, name='create_conversation'),
    url(r'^conversation/message/get/(?P<message_id>[^/]+)/', get_message, name='get_message'),
    url(r'^conversation/message/new/(?P<conversation_id>[^/]+)/', create_message, name='create_message'),
    url(r'^conversation/messages/all/(?P<conversation_id>[^/]+)/', get_conversation_messages, name='conversation_messages'),
    url(r'^conversation/(?P<conversation_id>[^/]+)/', serve_conversation, name='serve_conversation'),
    url(r'^', index, name='index'),
]