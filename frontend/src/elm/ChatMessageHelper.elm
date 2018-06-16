module ChatMessageHelper exposing (..)   

import Json.Decode

import Http

getAllMessages msg conversationID = 
  let
    decodeAllMessages = Json.Decode.string
    url = "http://blah/memes/" ++ conversationID
    request =
      Http.get url decodeAllMessages
  in
    Http.send msg request