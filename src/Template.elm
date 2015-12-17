module Template (..) where

import NestedTemplate exposing (parse, TemplateElement(GadgetEl, PanelEl, LayoutEl))
import List exposing (foldl, map)
import Dict exposing (Dict)


type alias Id =
    String


type TemplateElement
    = GadgetEl Gadget
    | PanelEl Panel
    | LayoutEl Layout


type alias Layout =
    { type' : String
    , children : List Id
    , id : String
    }


type alias Gadget =
    { label : String
    , type' : String
    , json : String
    , id : String
    }


type alias Panel =
    { label : String
    , proposal : Bool
    , children : List Id
    , id : String
    }


type alias Elements =
    Dict Id TemplateElement


type alias Template =
    { children : List String
    , elements : Elements
    }


emptyTemplate =
    { children = []
    , elements = Dict.empty
    }


extractId : NestedTemplate.TemplateElement -> String
extractId elem =
    case elem of
        NestedTemplate.GadgetEl el ->
            el.id

        NestedTemplate.PanelEl el ->
            el.id

        NestedTemplate.LayoutEl el ->
            el.id


collectElems : NestedTemplate.TemplateElement -> Dict String TemplateElement -> Dict String TemplateElement
collectElems elem memo =
    case elem of
        NestedTemplate.GadgetEl el ->
            Dict.insert el.id (GadgetEl el) memo

        NestedTemplate.PanelEl el ->
            Dict.insert
                el.id
                (PanelEl { el | children = (map extractId el.children) })
                (foldl collectElems memo el.children)

        NestedTemplate.LayoutEl el ->
            Dict.insert
                el.id
                (LayoutEl { el | children = (map extractId el.children) })
                (foldl collectElems memo el.children)


childIds : NestedTemplate.Template -> List Id
childIds nested =
    map extractId nested.template


flattenTemplate : NestedTemplate.Template -> Template
flattenTemplate nested =
    { children = (childIds nested)
    , elements = (foldl collectElems Dict.empty nested.template)
    }


fromString : String -> Result String Template
fromString tString =
    --Result.map flattenTemplate (parse tString)
    Ok (flattenTemplate NestedTemplate.emptyTemplate)
