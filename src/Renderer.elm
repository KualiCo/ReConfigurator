module Renderer (..) where

import Html.Attributes exposing (..)
import Html exposing (..)
import Template exposing (TemplateElement(GadgetEl, PanelEl, LayoutEl), Template, Id, Elements)
import List exposing (map)
import Dict exposing (Dict)


renderId : Elements -> Id -> Html
renderId elements id =
    let
        maybeElem = Dict.get id elements
    in
        case maybeElem of
            Just elem ->
                renderElement elements elem

            Nothing ->
                div [] [ text ("Element with id " ++ id ++ " not found.") ]


renderElement : Elements -> TemplateElement -> Html
renderElement elements elem =
    case elem of
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
                , div [ class "children" ] (map (renderId elements) e.children)
                ]

        LayoutEl e ->
            if e.type' == "Row" then
                div
                    [ class "row" ]
                    (map (renderId elements) e.children)
            else
                div
                    [ class "column" ]
                    (map (renderId elements) e.children)


render : Template -> Html
render tpl =
    div
        []
        [ div
            []
            (map (renderId tpl.elements) tpl.children)
        ]


renderError : String -> Html
renderError msg =
    div
        []
        [ h1 [] [ text "Oh no, there was an error parsing the template!" ]
        , div [] [ text msg ]
        ]
