module Main exposing (..)

import Html exposing (..)

import Keyboard

type alias Model =
    {
        currentSlide : Int,
        counter: Int,
        mouseX: Int, 
        mouseY: Int
    }

type Msg
    = Increment
    | Decrement
    | KeyMsg Keyboard.KeyCode
    | MouseMovement Int Int

initState : Model 
initState = { currentSlide = 0, counter = 0, mouseX = 0, mouseY = 0 }

init : ( Model, Cmd Msg )
init =
    ( initState, Cmd.none )

-- Model updates here
update : Msg -> Model -> ( Model, Cmd msg )
update msg model = ( model, Cmd.none )

-- Put websockets subscriotions here
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

-- View code goes here
view : Model -> Html Msg
view model = div [] [text "what is this"]

-- Entry point
main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }