module Actions (..) where

import Template exposing (Template, Id, TemplateElement, emptyElement)


type HoverSide
    = Left
    | Right
    | Top
    | Bottom


type alias Drag =
    TemplateElement

noDrag = emptyElement

type alias HoverInfo =
    { id : Id
    , side : HoverSide
    }


type Action
    = NoOp
    | UpdateTemplate Template
    | ShowError String
    | Hover HoverInfo
    | SetDragging Drag
    | Move Id HoverSide Id
