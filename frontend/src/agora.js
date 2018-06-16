class VideoChat extends HTMLElement {
    constructor () {
        super();
    }

    connectedCallback() {
        console.log('I am born rendered');
    }

    disconnectedCallback() {

    }

    attributeChangedCallback(attrName, oldVal, newVal) {

    }

    adoptedCallback() {
        
    }
}

export default {
    VideoChat
}