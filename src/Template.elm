module Template (..) where

import Dict exposing (Dict)


type alias Uuid =
    String


type TemplateElement
    = Gadget
        { id : Uuid
        , label : String
        , type' : String
        , json : String
        }
    | Panel
        { id : Uuid
        , label : String
        , proposal : Bool
        , children : List Uuid
        }
    | Layout
        { id : Uuid
        , type' : String
        , children : List Uuid
        }


type alias Template =
    { template : List String
    , elements : Dict Uuid TemplateElement
    }


emptyTemplate =
    { template = []
    , elements = Dict.empty
    }



--fromString : String -> Result String Template
--fromString tString =
--    D.decodeString
--        templateDecoder
--        tString
