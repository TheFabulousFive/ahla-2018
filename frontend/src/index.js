import Elm from './elm/Main.elm';

import './scss/style.scss'

window.onload = function () {
	var node = document.getElementById('main');
	var app = Elm.Main.embed(node);
}
