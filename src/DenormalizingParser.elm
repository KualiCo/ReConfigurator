module DenormalizingParser where

import Html exposing (div, text)
import Json.Decode exposing (object2, string, (:=), value, customDecoder, Decoder, decodeString)
import Json.Decode.Extra exposing ((|:))


type alias Child =
    { id : String
    , name : String
    , children : List String
    }


type alias Root =
    { elements : Dict String Child
    , children : List String
    }


sample = """
{
    "children": [
        {
            "name": "first",
            "children" : [ {"name": "child of first"} ]
        }
        {
            "name": "second",
            "children" : [ {"name": "child of second"} ]
        },
    ]
}
"""


childParser : Decoder (Child, List Child)
childParser =
    succeed Child
        |: succeed "an ID"
        |: ("name" := string)
        |: 


decoder : Decoder Root
decoder =
    succeed Root
        |: ("a" := string)



-- This extracts the entire object as a string


main =
    div
        []
        [ text <| toString (decodeString decoder sample)
        ]

