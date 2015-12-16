module FancyParse (..) where

import Html exposing (div, text)
import Json.Decode exposing (succeed, string, (:=), value, customDecoder, Decoder, decodeString)
import Json.Decode.Extra exposing ((|:))


type alias Foo =
    { a : String
    , b : String
    , c : String
    }


sample =
    """{"a" : "apples", "b": "bannanas", "c": "carrots"}"""


decoder : Decoder Foo
decoder =
    succeed Foo
        |: ("a" := string)
        |: ("b" := string)
        |: ("c" := string)


main =
    div
        []
        [ text <| toString (decodeString decoder sample)
        ]
