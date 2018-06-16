module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Keyboard
import WebSocket


type alias ChatMessage = 
    {
        uid: String,
        name: String,
        text: String,
        isPatient: Bool
    }

type alias Model =
    {
        messages: List(ChatMessage),
        message: String 
    }

type Msg
    = Increment
    | Decrement
    | KeyMsg Keyboard.KeyCode
    | MouseMovement Int Int
    | WSMessage String
    | Input String
    | Messages List
    -- | MessagesFromClinicians List

mockMessages = [{
            name = "Steve", 
            uid = "wwwww",
            text = "I am here",
            isPatient = True
        }, {
            name = "Steve", 
            uid = "wwwww",
            text = "I am here",
            isPatient = True
        },{
            name = "Sue", 
            uid = "wwwww",
            text = "I am here",
            isPatient = False
        },
        {
            name = "Steve", 
            uid = "wwwww",
            text = "I am here",
            isPatient = True
        }]

initState : Model 
initState = { messages = mockMessages, message = "" }

init : ( Model, Cmd Msg )
init =
    ( initState, Cmd.none )
    
-- Messages = [ [ "Hi", "I need help", "I'm sad", "My dog died"], ["oh wow"]]

-- Model updates here
update : Msg -> Model -> ( Model, Cmd msg )
update msg model = 
    case msg of
        WSMessage ws_msg ->
            ( { model | message = ws_msg } , Cmd.none )
        _ ->
            ( model, Cmd.none )

-- Put websockets subscriotions here
subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch [
    WebSocket.listen "ws://localhost:8000/" WSMessage
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
            chatClose [] [text "<-"]
            ,shareIdentitySwitch [] [text "Share your Identity"]
           ]
            ,chatFeed model.messages
            ,chatFooter [] [
                chatInput [] [
                    input [placeholder "message here"] []
                ]
                ,chatSend [] [
                    button [] [ text "Send Message" ]   
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