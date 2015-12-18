module Main (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Template exposing (Template, emptyTemplate, Id, TemplateElement)
import Renderer exposing (render, renderError)
import StartApp
import Effects exposing (Effects)
import Signal exposing (Address)
import Task exposing (Task)
import Actions exposing (..)
import Ajax exposing (fetchTemplate, ApiInfo)
import Dict exposing (map)


view : Address Action -> Model -> Html
view address model =
    div
        []
        [ nav
            []
            [ h1
                []
                [ span [ class "heavy" ] [ text "Re" ]
                , span [ class "light" ] [ text "Configurator" ]
                ]
            ]
        , div
            [ class "wrapper" ]
            [ if model.error == "" then
                render address model.template model.hovering model.dragging
              else
                renderError model.error
            ]
        ]


type alias Model =
    { template : Template
    , apiInfo : ApiInfo
    , editingApiInfo : ApiInfo
    , error : String
    , hovering : HoverInfo
    , dragging : Drag
    }


port storedApiInfo : ApiInfo
init =
    ( { template = emptyTemplate
      , apiInfo =
            storedApiInfo
      , editingApiInfo =
            { key = ""
            , url = ""
            }
      , error = ""
      , hovering = { id = "", side = Top }
      , dragging = noDrag
      }
    , fetchTemplate UpdateTemplate ShowError storedApiInfo
    )


withoutId : Id -> List Id -> List Id
withoutId removalId children =
    List.filter (\id -> id /= removalId) children


reInsertId : Id -> HoverSide -> Id -> List Id -> List Id
reInsertId movingId side targetId children =
    List.foldl
        (\id memo ->
            if id == targetId then
                case side of
                    Top ->
                        List.append memo [ movingId, id ]

                    Bottom ->
                        List.append memo [ id, movingId ]

                    Left ->
                        List.append memo [ movingId, id ]

                    Right ->
                        List.append memo [ id, movingId ]
            else
                List.append memo [ id ]
        )
        []
        children


update : Action -> Model -> ( Model, Effects Action )
update action model =
    case action of
        NoOp ->
            ( model
            , Effects.none
            )

        UpdateTemplate t ->
            ( { model | template = t }
            , Effects.none
            )

        ShowError e ->
            ( { model | error = e }
            , Effects.none
            )

        Hover info ->
            ( { model | hovering = info }
            , Effects.none
            )

        SetDragging val ->
            ( { model | dragging = val }
            , Effects.none
            )

        Move movingId side targetId ->
            let
                removedFromElements =
                    map
                        (\_ elem -> { elem | children = (withoutId movingId elem.children) })
                        model.template.elements

                reinsertedInElements =
                    map
                        (\_ elem -> { elem | children = (reInsertId movingId side targetId elem.children) })
                        removedFromElements

                removedFromRootChildren =
                    withoutId movingId model.template.children

                reinsertedInRootChildren =
                    reInsertId movingId side targetId removedFromRootChildren

                template = model.template

                updatedTemplate = { template | elements = reinsertedInElements, children = reinsertedInRootChildren }
            in
                ( { model | template = updatedTemplate }
                , Effects.none
                )


app =
    StartApp.start
        { init = init
        , view = view
        , update = update
        , inputs = []
        }


main =
    app.html


port tasks : Signal (Task.Task Effects.Never ())
port tasks =
    app.tasks
