module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Keyboard
import WebSocket
import Json.Decode exposing (decodeString, field, Decoder, int, string, map4, bool)
import Json.Encode
import ChatMessageHelper

type alias ChatMessage = 
    {
        timestamp: Int,
        uid: String,
        name: String,
        text: String,
        isPatient: Bool
    }

type alias Model =
    {
        messages: List(ChatMessage),
        message: String,
        currentMessageBuffer: String
    }

type Msg
    = Increment
    | Decrement
    | KeyMsg Keyboard.KeyCode
    | MouseMovement Int Int
    | WSMessage String
    | SendChatMessage
    | Input String
    | Messages List
    | OnMessageTextInput String
    -- | MessagesFromClinicians List

chatWSEnpoint = "ws://localhost:8000/user/"

mockMessages = [{
            timestamp = 0000000000,
            name = "Steve", 
            uid = "wwwww",
            text = "I am here",
            isPatient = True
        }, {
            timestamp = 0000000000,
            name = "Steve", 
            uid = "wwwww",
            text = "I am here",
            isPatient = True
        },{
            timestamp = 0000000000,
            name = "Sue", 
            uid = "wwwww",
            text = "I am here",
            isPatient = False
        },
        {
            timestamp = 0000000000,
            name = "Steve", 
            uid = "wwwww",
            text = "I am here",
            isPatient = True
        }]

initState : Model 
initState = { messages = mockMessages, currentMessageBuffer = "", message = "" }

init : ( Model, Cmd Msg )
init =
    ( initState, Cmd.none )
    
-- Messages = [ [ "Hi", "I need help", "I'm sad", "My dog died"], ["oh wow"]]

decodeMessage m = 
    -- map2 ChatMessage (field "uid" string) (field "name" string) (field "message" string) (field "is_patient" bool)
    case m of 
        Ok s -> s
        Err err -> ":("

encodeChatMessage uid message =
    let 
        chatEncoder = 
            Json.Encode.object
                [
                    ("uid", Json.Encode.string uid),
                    ("message", Json.Encode.string message)
                ]
    in
        Json.Encode.encode 0 chatEncoder        

-- Model updates here
update : Msg -> Model -> ( Model, Cmd msg )
update msg model = 
    case msg of
        OnMessageTextInput message ->
            ( { model | currentMessageBuffer = message}, Cmd.none)
        WSMessage ws_msg ->
            let
                result = decodeString (field "message" string) ws_msg
                resultMessage = decodeMessage <| result
                udpatedMessageFeed = model.messages ++ [{
                    timestamp = 0000000000,
                    name = "Sue",
                    uid = "wwwww",
                    text = resultMessage,
                    isPatient = False
                }]
            in
                ( { model | message = resultMessage, messages = udpatedMessageFeed} , Cmd.none )
        SendChatMessage ->
            let
                messageJSON = 
                    encodeChatMessage "0000" model.currentMessageBuffer
            in
                ( { model | currentMessageBuffer = "" }, WebSocket.send chatWSEnpoint messageJSON)
        _ ->
            ( model, Cmd.none )

-- Put websockets subscriotions here
subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch [
    WebSocket.listen chatWSEnpoint WSMessage
    ]

videoChatElement : List (Attribute msg) -> List (Html msg) -> Html msg
videoChatElement =
    Html.node "video-chat"
    
appContainer attrs =
    div <| [class "protea-app-wrapper"] ++ attrs
-- Chat
chatContainer attrs =
    div <| [class "chat-container semantic ui stuff"] ++ attrs

chatClose attrs =
    div <| [class "semantic ui stuff"] ++ attrs

chatInput attrs =
    div <| [class "semantic ui stuff"] ++ attrs

chatSend attrs =
    button <| [class "semantic ui stuff"] ++ attrs

shareIdentitySwitch attrs =
    button <| [class "semantic ui stuff"] ++ attrs

chatHeader attrs =
    div <| [class "chat-header semantic ui stuff"] ++ attrs

chatFooter attrs = 
    div <| [class "chat-footer"] ++ attrs

chatFeed messages = 
    let
        formatMessage message = 
            let
                isUserPatient = case message.isPatient of
                    True -> "user-patient"
                    False -> "user-doctor"
            in
                div [class <| "chat-item " ++ isUserPatient] [
                    span [class "chat-message-name"] [text message.name]
                    ,p [class "chat-message-text"] [text message.text]
                ]
    in
        List.map formatMessage messages |> 
            div [class "chat-feed"]

-- View code goes here
view : Model -> Html Msg

view model = 
    appContainer [] [
        
       chatContainer [] [
           chatHeader[] [
            chatClose [] [text "<-", text model.message, text model.currentMessageBuffer]
            ,shareIdentitySwitch [] [text "Share your Identity"]
           ]
            ,chatFeed model.messages
            ,chatFooter [] [
                chatInput [] [
                    input [onInput OnMessageTextInput, 
                        value model.currentMessageBuffer, 
                        placeholder "Enter message here"] []
                ]
                ,chatSend [] [
                    button [onClick <| SendChatMessage] [ text "Send Message" ]   
                ]
            ]
        ]
        ]

-- Entry point
main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }