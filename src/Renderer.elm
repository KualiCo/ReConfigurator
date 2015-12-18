module Renderer (..) where

import Html.Events exposing (onWithOptions, on)
import Html.Attributes exposing (..)
import Html exposing (..)
import Template exposing (TemplateElement, Template, Id, Elements)
import List exposing (map)
import Dict exposing (Dict)
import Signal exposing (Address, message)
import Actions exposing (..)
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


addVertDropzones : Address Action -> Drag -> HoverInfo -> Id -> Html -> Html
addVertDropzones address dragging hovering id child =
    let
        hoverClass =
            if hovering.id == id then
                hoverClassForSide hovering.side
            else
                ""

        addDropzoneAttrs' = addDropzoneAttrs address dragging
    in
        if dragging.id /= "" && dragging.id /= id then
            div
                [ class ("dzWrapper " ++ hoverClass) ]
                [ div
                    (addDropzoneAttrs'
                        id
                        [ class "dzT" ]
                        Top
                    )
                    []
                , child
                , div
                    (addDropzoneAttrs'
                        id
                        [ class "dzB" ]
                        Bottom
                    )
                    []
                ]
        else
            child


addDropzoneAttrs : Address Action -> Drag -> Id -> List Attribute -> HoverSide -> List Attribute
addDropzoneAttrs address dragging id currentAttrs side =
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
            (\_ -> message address (Hover { id = "", side = Top }))
        , on
            "drop"
            Json.value
            (\_ -> message address (Move dragging.id side id))
        ]


addDraggableAttrs : Address Action -> TemplateElement -> List Attribute -> List Attribute
addDraggableAttrs address elem existingAttrs =
    List.append
        existingAttrs
        [ draggable "true"
        , on "drag" Json.value (\_ -> message address (SetDragging elem))
        , on "dragend" Json.value (\_ -> message address (SetDragging noDrag))
        ]


renderId : Address Action -> Drag -> HoverInfo -> Elements -> Id -> Html
renderId address dragging hovering elements id =
    let
        renderElement' = renderElement address dragging hovering elements
    in
        Maybe.withDefault
            (div [] [ text ("Element with id " ++ id ++ " not found.") ])
            (Maybe.map renderElement' (Dict.get id elements))


renderElement : Address Action -> Drag -> HoverInfo -> Elements -> TemplateElement -> Html
renderElement address dragging hovering elements elem =
    let
        renderId' = renderId address dragging hovering elements

        addDraggableAttrs' = addDraggableAttrs address

        addVertDropzones' = addVertDropzones address dragging hovering
    in
        if elem.type' == "Row" then
            div
                [ class "row" ]
                (map renderId' elem.children)
        else if elem.type' == "Column" then
            div
                [ class "column" ]
                (map renderId' elem.children)
        else if elem.type' == "Panel" then
            addVertDropzones'
                elem.id
                <| div
                    (addDraggableAttrs'
                        elem
                        [ class "panel"
                        , key elem.id
                        ]
                    )
                    [ div [ class "panelLabel" ] [ text elem.label ]
                    , div [ class "children" ] (map renderId' elem.children)
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


render : Address Action -> Template -> HoverInfo -> Drag -> Html
render address tpl hovering dragging =
    let
        elements = tpl.elements

        renderId' = renderId address dragging hovering elements
    in
        div
            []
            [ div
                []
                (map renderId' tpl.children)
            ]


renderError : String -> Html
renderError msg =
    div
        []
        [ h1 [] [ text "Oh no, there was an error parsing the template!" ]
        , div [] [ text msg ]
        ]
