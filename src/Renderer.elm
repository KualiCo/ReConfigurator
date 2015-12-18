module Renderer (..) where

import Html.Events exposing (onWithOptions, on)
import Html.Attributes exposing (..)
import Html exposing (..)
import Template exposing (TemplateElement, Template, Id, Elements)
import List exposing (indexedMap)
import Dict exposing (Dict)
import Signal exposing (Address, message)
import Actions exposing (..)
import Json.Decode as Json


dropzone : Address Action -> Drag -> HoverInfo -> TemplateElement -> HoverSide -> Html
dropzone address dragging hovering elem side =
    let
        addDropzoneAttrs' = addDropzoneAttrs address dragging

        hoverClass =
            if hovering.id == elem.id && hovering.side == side then
                " hovering"
            else
                ""

        dzClass =
            case side of
                Top ->
                    "dzH"

                Bottom ->
                    "dzH"

                Left ->
                    "dzV"

                Right ->
                    "dzV"
    in
        div
            [ class ("dzWrapper" ++ hoverClass) ]
            [ div (addDropzoneAttrs' elem.id [ class dzClass ] side) []
            ]


addDropZones : Address Action -> Drag -> HoverInfo -> Int -> TemplateElement -> Html -> Html
addDropZones address dragging hovering idx elem child =
    let
        dropzone' = dropzone address dragging hovering

        children =
            if idx == 0 then
                [ dropzone' elem Top, child, dropzone' elem Bottom ]
            else
                [ child, dropzone' elem Bottom ]
    in
        if dragging.id /= "" && dragging.id /= elem.id then
            div [] children
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


renderId : Address Action -> Drag -> HoverInfo -> Elements -> Int -> Id -> Html
renderId address dragging hovering elements idx id =
    let
        renderElement' = renderElement address dragging hovering elements idx
    in
        Maybe.withDefault
            (div [] [ text ("Element with id " ++ id ++ " not found.") ])
            (Maybe.map renderElement' (Dict.get id elements))


renderElement : Address Action -> Drag -> HoverInfo -> Elements -> Int -> TemplateElement -> Html
renderElement address dragging hovering elements idx elem =
    let
        renderId' = renderId address dragging hovering elements

        addDraggableAttrs' = addDraggableAttrs address

        addDropZones' = addDropZones address dragging hovering idx
    in
        if elem.type' == "Row" then
            div
                [ class "row" ]
                (indexedMap renderId' elem.children)
        else if elem.type' == "Column" then
            div
                [ class "column" ]
                (indexedMap renderId' elem.children)
        else if elem.type' == "Panel" then
            addDropZones'
                elem
                <| div
                    (addDraggableAttrs'
                        elem
                        [ class "panel"
                        , key elem.id
                        ]
                    )
                    [ div [ class "panelLabel" ] [ text elem.label ]
                    , div [ class "children" ] (indexedMap renderId' elem.children)
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
                (indexedMap renderId' tpl.children)
            ]


renderError : String -> Html
renderError msg =
    div
        []
        [ h1 [] [ text "Oh no, there was an error parsing the template!" ]
        , div [] [ text msg ]
        ]
