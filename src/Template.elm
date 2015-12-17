module Template (..) where

import NestedTemplate exposing (parse, TemplateElement, ChildElements(ChildElements), children)
import List exposing (foldl, map)
import Dict exposing (Dict)


type alias Id =
    String


type alias TemplateElement =
    { type' : String
    , children : List Id
    , label : String
    , json : String
    , id : String
    }


type alias Elements =
    Dict Id TemplateElement


type alias Template =
    { children : List Id
    , elements : Elements
    }


emptyTemplate =
    { children = []
    , elements = Dict.empty
    }


collectElems : NestedTemplate.TemplateElement -> Dict String TemplateElement -> Dict String TemplateElement
collectElems elem memo =
    Dict.insert
        elem.id
        { elem | children = (map .id (children elem)) }
        (foldl collectElems memo (children elem))


flattenTemplate : NestedTemplate.Template -> Template
flattenTemplate nested =
    { children = (map .id (children nested))
    , elements = (foldl collectElems Dict.empty (children nested))
    }
