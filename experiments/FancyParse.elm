module FancyParse (..) where

import Html exposing (div, text)
import Json.Decode exposing (object2, string, (:=), value, customDecoder, Decoder, decodeString)


type alias Foo =
    { a : String
    , json : String
    }


sample =
    """{"a" : "apples", "b": {"c": "see?"}}"""


objectAsString : Decoder String
objectAsString =
    customDecoder value (\json -> Ok (toString json))


decoder : Decoder Foo
decoder =
    object2
        Foo
        ("a" := string)
        -- This extracts a field from an object
        objectAsString



-- This extracts the entire object as a string


main =
    div
        []
        [ text <| toString (decodeString decoder sample)
        ]
