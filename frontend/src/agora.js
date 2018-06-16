class VideoChat extends HTMLElement {
    constructor () {
        super();
        this.client = AgoraRTC.createClient({mode:'interop'});

        var client = this.client;
        var appid = '3e3e005a3ec343bca61e9792f414eb0c';

        client.init(appid, function(){
            console.log("AgoraRTC client initialized");
        });
    }

    connectedCallback() {
        console.log('I am born rendered');
        var container = document.createElement('div');
        container.setAttribute('id', 'agora-remote');
        container.style.width = '500px';
        container.style.height = '500px';
        this.appendChild(container);

        var client = this.client;

        client.join(null, "webtest", undefined, function(uid){
            console.log("User " + uid + " join channel successfully");
            console.log("Timestamp: " + Date.now());
            
            var stream = AgoraRTC.createStream({
                streamID: uid,
                audio:true,
                video:true,
                screen:false
            });

            stream.setVideoProfile("480p_4");
            stream.init(function(){
                console.log("Local stream initialized");

                client.publish(stream, function(err){
                    console.log("Publish stream failed", err);
                    console.log('I AM THE STREAM', stream);
                });

                client.on('stream-added', function(evt) {
                    var stream = evt.stream;
                    console.log("New stream added: " + stream.getId());
                    console.log("Timestamp: " + Date.now());
                    console.log("Subscribe ", stream);

                    client.subscribe(stream, function(err) {
                        console.log("Subscribe stream failed", err);
                   });

                   stream.play("agora-remote");                
                });
   
            });
            
            client.on('peer-leave', function(evt) {
                console.log("Peer has left: " + evt.uid);
                console.log("Timestamp: " + Date.now());
                console.log(evt);
            });
            
            /*
            @event: stream-subscribed when a stream is successfully subscribed
            */
            client.on('stream-subscribed', function(evt) {
                var stream = evt.stream;
                console.log("Got stream-subscribed event");
                console.log("Timestamp: " + Date.now());
                console.log("Subscribe remote stream successfully: " + stream.getId());
                console.log(evt);
            });

            client.on("stream-removed", function(evt) {
                var stream = evt.stream;
                console.log("Stream removed: " + evt.stream.getId());
                console.log("Timestamp: " + Date.now());
                console.log(evt);
            });
        });   

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