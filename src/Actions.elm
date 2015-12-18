module Actions (..) where

import Template exposing (Template, Id)


type HoverSide
    = Left
    | Right
    | Top
    | Bottom


type alias HoverInfo =
    { id : Id
    , side : HoverSide
    }


type Action
    = NoOp
    | UpdateTemplate Template
    | ShowError String
    | Hover HoverInfo
    | SetDragging Id
    | Move Id HoverSide Id
