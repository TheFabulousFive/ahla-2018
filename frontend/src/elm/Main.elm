module Main exposing (..)

import Html exposing (..)

import Keyboard
import WebSocket


type alias Model =
    {
        currentSlide : Int,
        counter: Int,
        mouseX: Int, 
        mouseY: Int,
        message: String
    }

type Msg
    = Increment
    | Decrement
    | KeyMsg Keyboard.KeyCode
    | MouseMovement Int Int
    | WSMessage String

initState : Model 
initState = { currentSlide = 0, counter = 0, mouseX = 0, mouseY = 0, message = "" }

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
    WebSocket.listen "ws://localhost:8081/" WSMessage
    ]

-- View code goes here
view : Model -> Html Msg
view model = div [] [text "what is this", text model.message ]

-- Entry point
main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }