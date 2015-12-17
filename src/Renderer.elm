module Renderer (..) where

import Html.Events exposing (onWithOptions, on)
import Html.Attributes exposing (..)
import Html exposing (..)
import Template exposing (TemplateElement, Template, Id, Elements)
import List exposing (map)
import Dict exposing (Dict)
import Signal exposing (Address, message)
import Actions exposing (Action, Action(Hover, SetDragging), HoverSide(Top, Bottom, Left, Right, NoHover), HoverInfo)
import Json.Decode as Json


hoverClassForSide side =
    case side of
        Top ->
            "hovering-top"

        Bottom ->
            "hovering-bottom"

        Left ->
            "hovering-left"

        Right ->
            "hovering-right"

        NoHover ->
            ""


render : Address Action -> Template -> HoverInfo -> Id -> Html
render address tpl hovering dragging =
    let
        elements = tpl.elements

        renderId id =
            Maybe.withDefault
                (div [] [ text ("Element with id " ++ id ++ " not found.") ])
                (Maybe.map renderElement (Dict.get id elements))

        hoverableClass id currentClasses =
            if hovering.id == id then
                currentClasses ++ " hovering"
            else
                currentClasses

        addDropzoneAttrs id currentAttrs side =
            List.append
                currentAttrs
                [ attribute "dropzone" "move"
                , attribute "ondragenter" "return false"
                , onWithOptions
                    "dragover"
                    { preventDefault = True, stopPropagation = False }
                    Json.value
                    (\_ -> message address (Hover { id = id, side = side }))
                , on
                    "dragleave"
                    Json.value
                    (\_ -> message address (Hover { id = "", side = NoHover }))
                  --, on
                  --    "drop"
                  --    Json.value
                  --    (\_ -> message address (Move dragging side id))
                ]

        addVertDropzones id child =
            let
                hoverClass =
                    if hovering.id == id then
                        hoverClassForSide hovering.side
                    else
                        ""
            in
                if dragging /= "" && dragging /= id then
                    div
                        [ class ("dzWrapper " ++ hoverClass) ]
                        [ div
                            (addDropzoneAttrs
                                id
                                [ class "dzT" ]
                                Top
                            )
                            []
                        , child
                        , div
                            (addDropzoneAttrs
                                id
                                [ class "dzB" ]
                                Bottom
                            )
                            []
                        ]
                else
                    child

        addDraggableAttrs id existingAttrs =
            List.append
                existingAttrs
                [ draggable "true"
                , on "drag" Json.value (\_ -> message address (SetDragging id))
                , on "dragend" Json.value (\_ -> message address (SetDragging ""))
                ]

        renderElement elem =
            if elem.type' == "Row" then
                div
                    [ class "row" ]
                    (map renderId elem.children)
            else if elem.type' == "Column" then
                div
                    [ class "column" ]
                    (map renderId elem.children)
            else if elem.type' == "Panel" then
                addVertDropzones
                    elem.id
                    <| div
                        (addDraggableAttrs
                            elem.id
                            [ class "panel"
                            , key elem.id
                            ]
                        )
                        [ div [ class "panelLabel" ] [ text elem.label ]
                        , div [ class "children" ] (map renderId elem.children)
                        ]
            else
                div
                    [ class "gadget" ]
                    [ div
                        [ class "label" ]
                        [ text
                            (if elem.label == "" then
                                "No label"
                             else
                                elem.label
                            )
                        ]
                    , div [ class "type" ] [ text elem.type' ]
                    ]
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
