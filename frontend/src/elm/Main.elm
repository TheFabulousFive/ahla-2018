module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Keyboard
import WebSocket
import Json.Decode exposing (decodeString, field, Decoder, int, string, float, map5, bool)
import Json.Encode
import Http

type alias ChatMessage = 
    {
        timestamp: Float,
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
    | ConfirmCreation (Result Http.Error String)
    -- | MessagesFromClinicians List

chatWSEnpoint = "ws://localhost:8000/user/"

mockMessages = []

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
            [    {
            timestamp =  222,
            name = "Steve", 
            uid = "wwwww",
            text = (toString err),
            isPatient = True
        }]

messageListDecoder = map5 ChatMessage (field "created_at" float) (field "id" string) (field "username" string) (field "text" string) (field "is_patient" bool)

getAllMessages conversationID = 
  let
     
    url = "http://localhost:8000/user/conversation/messages/all/" ++ conversationID ++ "/"
    request =
      Http.getString url
  in
    Http.send ReceiveMessages request

makeNewMessage conversationID message = 
    let
        url = "http://localhost:8000/user/conversation/message/new/" ++ conversationID ++ "/"
        submitBody = Http.multipartBody [Http.stringPart "text" message]
        request = Http.post url submitBody string
    in
        Http.send ConfirmCreation request

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
                    timestamp = 0000000000,
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
                ( { model | currentMessageBuffer = "" }, makeNewMessage model.conversationID model.currentMessageBuffer)
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
    div <| [class "ui card"] ++ attrs
-- Chat
chatContainer attrs =
    div <| [class "content"] ++ attrs

chatClose attrs =
    div <| [class "window close icon"] ++ attrs

chatInput attrs =
    div <| [class "semantic ui stuff"] ++ attrs

chatSend attrs =
    button <| [class "ui right labeled icon button"] ++ attrs

shareIdentitySwitch attrs =
    button <| [class "ui slider checkbox"] ++ attrs

chatHeader attrs =
    div <| [class "chat-header header"] ++ attrs

chatFooter attrs = 
    div <| [class "chat-footer footer"] ++ attrs

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
           videoChatElement [] [],
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