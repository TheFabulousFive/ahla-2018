from channels.routing import route, include
from channels.staticfiles import StaticFilesConsumer
from .consumers import ws_connect, ws_message, ws_disconnect

user_routes = [
    route('websocket.connect', ws_connect),
    route('websocket.disconnect', ws_disconnect),
    route('websocket.receive', ws_message),
]

channel_routing = [
    route('http.request', StaticFilesConsumer()),
    include(user_routes, path=r'^/user'),
]