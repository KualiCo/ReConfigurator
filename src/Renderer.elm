module Renderer (..) where

import Html.Events exposing (onWithOptions)
import Html.Attributes exposing (..)
import Html exposing (..)
import Template exposing (TemplateElement(GadgetEl, PanelEl, LayoutEl), Template, Id, Elements)
import List exposing (map)
import Dict exposing (Dict)
import Signal exposing (Address, message)
import Actions exposing (Action, Action(Hover), HoverSide(Bottom))
import Json.Decode


renderId : Address Action -> Elements -> Id -> Html
renderId address elements id =
    let
        maybeElem = Dict.get id elements
    in
        case maybeElem of
            Just elem ->
                renderElement address elements elem

            Nothing ->
                div [] [ text ("Element with id " ++ id ++ " not found.") ]


addHoverAttrs : Address Action -> Id -> List Attribute -> List Attribute
addHoverAttrs address id currentAttrs =
    List.append
        currentAttrs
        [ attribute "dropzone" "move"
        , attribute "ondragenter" "return false"
        , onWithOptions
            "dragover"
            { preventDefault = True, stopPropagation = False }
            Json.Decode.value
            (\_ -> message address (Hover { id = id, side = Bottom }))
        ]


renderElement : Address Action -> Elements -> TemplateElement -> Html
renderElement address elements elem =
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
                (addHoverAttrs
                    address
                    e.id
                    [ class "panel", draggable "true" ]
                )
                [ div [ class "panelLabel" ] [ text e.label ]
                , div [ class "children" ] (map (renderId address elements) e.children)
                ]

        LayoutEl e ->
            if e.type' == "Row" then
                div
                    [ class "row" ]
                    (map (renderId address elements) e.children)
            else
                div
                    [ class "column" ]
                    (map (renderId address elements) e.children)


render : Address Action -> Template -> Html
render address tpl =
    div
        []
        [ div
            []
            (map (renderId address tpl.elements) tpl.children)
        ]


renderError : String -> Html
renderError msg =
    div
        []
        [ h1 [] [ text "Oh no, there was an error parsing the template!" ]
        , div [] [ text msg ]
        ]
