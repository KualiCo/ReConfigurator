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


render : Address Action -> Template -> Html
render address tpl =
    let
        elements = tpl.elements

        renderId id =
            Maybe.withDefault
                (div [] [ text ("Element with id " ++ id ++ " not found.") ])
                (Maybe.map renderElement (Dict.get id elements))

        addHoverAttrs id currentAttrs =
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

        renderElement elem =
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
                            e.id
                            [ class "panel", draggable "true" ]
                        )
                        [ div [ class "panelLabel" ] [ text e.label ]
                        , div [ class "children" ] (map renderId e.children)
                        ]

                LayoutEl e ->
                    if e.type' == "Row" then
                        div
                            [ class "row" ]
                            (map renderId e.children)
                    else
                        div
                            [ class "column" ]
                            (map renderId e.children)
    in
        div
            []
            [ div
                []
                (map renderId tpl.children)
            ]


renderError : String -> Html
renderError msg =
    div
        []
        [ h1 [] [ text "Oh no, there was an error parsing the template!" ]
        , div [] [ text msg ]
        ]
