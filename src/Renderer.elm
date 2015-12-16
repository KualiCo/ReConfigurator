module Renderer (..) where

import Html.Attributes exposing (..)
import Html exposing (..)
import Template exposing (..)
import List exposing (map)


renderTElement el =
    case el of
        GadgetEl e ->
            div
                [ class "gadget" ]
                [ div
                    [ class "label" ]
                    [ text
                        (if e.label == "" then
                            "No label"
                         else
                            e.label
                        )
                    ]
                , div [ class "type" ] [ text e.type' ]
                ]

        PanelEl e ->
            div
                [ class "panel" ]
                [ div [ class "panelLabel" ] [ text e.label ]
                , div [ class "children" ] (map renderTElement e.children)
                ]

        LayoutEl e ->
            if e.type' == "Row" then
                div
                    [ class "row" ]
                    (map renderTElement e.children)
            else
                div
                    [ class "column" ]
                    (map renderTElement e.children)


render : Template -> Html
render tpl =
    div
        []
        [ div
            []
            (map renderTElement tpl.template)
        ]


renderError : String -> Html
renderError msg =
    div
        []
        [ h1 [] [ text "Oh no, there was an error parsing the template!" ]
        , div [] [ text msg ]
        ]
