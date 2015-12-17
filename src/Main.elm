module Main (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Template exposing (Template, emptyTemplate)
import Renderer exposing (render, renderError)
import StartApp
import Effects exposing (Effects)
import Signal exposing (Address)
import Task exposing (Task)
import Actions exposing (..)
import Ajax exposing (fetchTemplate, ApiInfo)


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
                render model.template
              else
                renderError model.error
            ]
        ]


type alias Model =
    { template : Template
    , apiInfo : ApiInfo
    , editingApiInfo : ApiInfo
    , error : String
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
      }
    , fetchTemplate UpdateTemplate ShowError storedApiInfo
    )


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
