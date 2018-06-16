module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Keyboard
import WebSocket
import Json.Decode exposing (decodeString, field, Decoder, int, string, map5, bool)
import Json.Encode
import Http

type alias ChatMessage = 
    {
        timestamp: String,
        uid: String,
        name: String,
        text: String,
        isPatient: Bool
    }

type alias Model =
    {
        messages: List(ChatMessage),
        message: String,
        currentMessageBuffer: String,
        conversationID: String
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
    | FetchAllMessages
    | ReceiveMessages  (Result Http.Error String)
    -- | MessagesFromClinicians List

chatWSEnpoint = "ws://localhost:8000/user/"

mockMessages = [{
            timestamp = "222",
            name = "Steve", 
            uid = "wwwww",
            text = "I am here",
            isPatient = True
        }, {
            timestamp =  "222",
            name = "Steve", 
            uid = "wwwww",
            text = "I am here",
            isPatient = True
        },{
            timestamp =  "222",
            name = "Sue", 
            uid = "wwwww",
            text = "I am here",
            isPatient = False
        },
        {
            timestamp =  "222",
            name = "Steve", 
            uid = "wwwww",
            text = "I am here",
            isPatient = True
        }]

initState : Model 
initState = { messages = mockMessages, currentMessageBuffer = "", message = "", conversationID = ""}

type alias Flags = 
    {
        conversationID : String    
    }

init : Flags -> ( Model, Cmd Msg )
init flags = 
    ( { initState | conversationID = flags.conversationID }, getAllMessages flags.conversationID )

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

extractArray k =
    case k of
        Ok s ->
            s
        Err err ->
            []

messageListDecoder = map5 ChatMessage (field "created_at" string) (field "uid" string) (field "name" string) (field "message" string) (field "is_patient" bool)

getAllMessages conversationID = 
  let
     
    url = "http://localhost:8000/user/conversation/messages/all/" ++ conversationID ++ "/"
    request =
      Http.getString url
  in
    Http.send ReceiveMessages request

-- Model updates here
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
    case msg of
        OnMessageTextInput message ->
            ( { model | currentMessageBuffer = message}, Cmd.none)
        WSMessage ws_msg ->
            let
                result = decodeString (field "message" string) ws_msg
                resultMessage = decodeMessage <| result
                udpatedMessageFeed = model.messages ++ [{
                    timestamp = "0000000000",
                    name = "Sue",
                    uid = "wwwww",
                    text = resultMessage,
                    isPatient = False
                }]
            in
                ( { model | message = resultMessage, messages = udpatedMessageFeed} , Cmd.none )

        FetchAllMessages ->
            ( model, getAllMessages model.conversationID)
            
        SendChatMessage ->
            let
                messageJSON = 
                    encodeChatMessage "0000" model.currentMessageBuffer
            in
                ( { model | currentMessageBuffer = "" }, WebSocket.send chatWSEnpoint messageJSON)
        ReceiveMessages (Ok s) ->
            let              
                listDecoder = Json.Decode.at ["data", "messages"] (Json.Decode.list messageListDecoder)
                newMessages = decodeString listDecoder s |> extractArray
            in
                ( { model | currentMessageBuffer = "", messages = newMessages }, Cmd.none)

        ReceiveMessages (Err err) ->
                ( { model | currentMessageBuffer = (toString err) }, Cmd.none)                
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
main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }