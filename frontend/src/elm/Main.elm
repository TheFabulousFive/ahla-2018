module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Keyboard
import WebSocket


type alias Model =
    {
        -- input : String
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

initState : Model 
initState = { message = "" }

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
    div <| [class "semantic ui stuff"] ++ attrs

chatClose attrs =
    div <| [class "semantic ui stuff"] ++ attrs

chatInput attrs =
    div <| [class "semantic ui stuff"] ++ attrs

chatSend attrs =
    button <| [class "semantic ui stuff"] ++ attrs

shareIdentitySwitch attrs =
    button <| [class "semantic ui stuff"] ++ attrs

chatHeader attrs =
    div <| [class "semantic ui stuff"] ++ attrs

-- View code goes here
view : Model -> Html Msg

view model = 
    appContainer [] [
        
       chatContainer [] [
           chatHeader[] [
            chatClose [] [text "<-"]
            ,shareIdentitySwitch [] [text "Share your Identity"]
           ]
            ,text "I am container"
            ,text "Pluto is not a planet"
            ,text model.message
            ,chatInput [] [
                input [placeholder "message here"] []
            ]
            ,chatSend [] [
                button [] [ text "Send Message" ]   
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