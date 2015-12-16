module Actions (..) where

import Template exposing (Template)


type Action
    = NoOp
    | UpdateTemplate Template
    | ShowError String
