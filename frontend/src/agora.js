class VideoChat extends HTMLElement {
    constructor () {
        super();
    }

    connectedCallback() {
        console.log('I am born rendered');
    }
}

export default {
    VideoChat
}