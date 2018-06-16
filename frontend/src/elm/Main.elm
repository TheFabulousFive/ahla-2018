module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, attribute)
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

initState : Model 
initState = { message = "" }

init : ( Model, Cmd Msg )
init =
    ( initState, Cmd.none )

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

roomID = attribute "room"

-- View code goes here
view : Model -> Html Msg

view model = 
    appContainer [] [
        text "This is a test"
       ,text model.message
        ,videoChatElement [roomID "webtest"] []
        -- -- User Info
        -- ,input [ placeholder "User name", onInput Username ] []
        -- ,[ button [ onClick Decrement ] [ text "Share Current Location" ]
        -- ,ul [class "users-near"]
        --     [ li [] [text "Talking"]
        --     , li [] [text "Listening"]
        --     ]
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