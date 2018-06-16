module Main exposing (..)

import Html exposing (..)
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

-- View code goes here
view : Model -> Html Msg
view model = div [] [ text "what is this", text model.message ]
    -- div []
    --     [ input [onInput Input, value model.input] []
    -- , button [onClick Send] [text "Send"]
    -- , div [] (List.map viewMessage (List.reverse model.messages))
    -- ]

-- Entry point
main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }