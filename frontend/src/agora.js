class VideoChat extends HTMLElement {
    constructor () {
        super();
        this.client = AgoraRTC.createClient({mode:'rtc'});
        var client = this.client;
        var appid = '3e3e005a3ec343bca61e9792f414eb0c';

        client.init(appid, function(){
            console.log("AgoraRTC client initialized");
        });
    }

    connectedCallback() {
        console.log('I am born rendered');
        this.roomID = this.getAttribute('room');
                
        var container = document.createElement('div');
        container.setAttribute('id', 'agora-remote');
        container.style.width = '500px';
        container.style.height = '500px';
        this.appendChild(container);

        var client = this.client;
        console.log('I am the room', this.roomID);

        client.join(null, this.roomID, undefined, function(uid){
            console.log("User " + uid + " join channel successfully");
            console.log("Timestamp: " + Date.now());

            console.log('I am the STATS', client);
            
            var stream = AgoraRTC.createStream({
                streamID: uid,
                audio:true,
                video:true,
                screen:false
            });

            stream.setVideoProfile("480p_4");
            stream.init(function(){
                console.log("Local stream initialized");       
                var localStream = stream;
                client.publish(stream, function(err){
                    console.log("Publish stream failed", err);
                });

                client.on('stream-added', function(evt) {
                    var stream = evt.stream;
                    console.log("New stream added: " + stream.getId());
                    console.log("Timestamp: " + Date.now());
                    console.log("Subscribe ", stream);
                    
                    client.publish(stream, function(err){
                        console.log("Publish stream failed", err);
                    });

                    client.subscribe(stream, function(err) {                        
                        console.log("Subscribe stream failed", err);
                   });
                });
   
            });
            
            client.on('peer-leave', function(evt) {
                console.log("Peer has left: " + evt.uid);
                console.log("Timestamp: " + Date.now());
                console.log(evt);
                var stream = evt.stream;
                stream.stop();
            });
            
            /*
            @event: stream-subscribed when a stream is successfully subscribed
            */
            client.on('stream-subscribed', function(evt) {
                var stream = evt.stream;
                console.log("Got stream-subscribed event");
                console.log("Timestamp: " + Date.now());
                console.log("Subscribe remote stream successfully: " + stream.getId(), uid);
                console.log(evt);

                if(stream.getId() !== uid) {
                    stream.play("agora-remote");
                }
            });

            client.on("stream-removed", function(evt) {
                var stream = evt.stream;
                console.log("Stream removed: " + evt.sctream.getId());
                console.log("Timestamp: " + Date.now());
                console.log(evt);
                stream.stop("agora-remote");
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