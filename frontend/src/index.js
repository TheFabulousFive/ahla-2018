import AgoraRTC from 'agora-rtc-sdk';

import Elm from './elm/Main.elm';
import agora from './agora.js';

import './scss/style.scss'

// Put custom elements here
customElements.define('video-chat', agora.VideoChat);

window.onload = function () {
	var node = document.getElementById('main');
	var app = Elm.Main.embed(node, {
		conversationID: window.conversation_id
	});
}
