class VideoChat extends HTMLElement {
    constructor () {
        super();
        this.client = AgoraRTC.createClient({mode:'interop'});

        var client = this.client;
        var appid = '3e3e005a3ec343bca61e9792f414eb0c';

        client.init(appid, function(){
            console.log("AgoraRTC client initialized");
        });
        client.join(null, "webtest", undefined, function(uid){
            console.log("User " + uid + " join channel successfully");
            console.log("Timestamp: " + Date.now());
        });   
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