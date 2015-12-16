module FancyParse (..) where

import Html exposing (div, text)
import Json.Decode as D exposing (object2, string, (:=), value, customDecoder, Decoder, decodeString)


type alias Gadget =
    { label : String
    , type' : String
    , json : String
    }


sample =
    """
{
    "categoryId":  "5a115780-5778-4c3e-866e-35da013ac332" ,
    "gKey":  "department" ,
    "label":  "Department" ,
    "mandatory": false ,
    "mandatoryForSubmission": true ,
    "parentCategoryGadgetGkey":  "colledge" ,
    "type":  "GroupsTypeahead"
}
    """


objectAsString =
    D.customDecoder D.value (\json -> Ok (toString json))


gadgetDecoder =
    D.object3
        Gadget
        ("label" := D.string)
        ("type" := D.string)
        objectAsString


main =
    div
        []
        [ text <| toString (decodeString gadgetDecoder sample)
        ]
