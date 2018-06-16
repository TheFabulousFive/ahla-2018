from channels import Group
import json
from channels.auth import channel_session_user, channel_session_user_from_http


@channel_session_user_from_http
def ws_connect(message):
    Group('users').add(message.reply_channel)
    Group('users').send({
        'text': json.dumps({
            'message': 'hello',
        })
    })


@channel_session_user_from_http
def ws_message(message):
    text = json.loads(message['text'])
    Group('users').send({
        'text': json.dumps({
            'message': text,
        })
    })


@channel_session_user_from_http
def ws_disconnect(message):
    Group('users').discard(message.reply_channel)
