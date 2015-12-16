module Dnd (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import StartApp.Simple exposing (start)
import Signal exposing (message, Address)
import Json.Decode


dragStyle =
    [ ( "width", "100px" )
    , ( "height", "100px" )
    , ( "background-color", "tomato" )
    , ( "margin", "1em" )
    , ( "padding", "1em" )
    , ( "color", "white" )
    ]


dropStyle =
    [ ( "width", "300px" )
    , ( "height", "300px" )
    , ( "background-color", "black" )
    , ( "margin", "1em" )
    , ( "padding", "1em" )
    , ( "color", "white" )
    ]


type alias Model =
    { draggingOver : Bool
    , dropCount : Int
    }


model : Model
model =
    { draggingOver = False
    , dropCount = 0
    }


render : Address Action -> Model -> Html
render address model =
    div
        []
        [ div
            [ draggable "yes"
            , style dragStyle
            , on "drop" Json.Decode.value (\_ -> Debug.log "DROPPING" (message address IncDropCount))
            ]
            [ text "DRAG ME YE LUBBARD" ]
        , div
            [ attribute "dropzone" "move"
            , attribute "ondragenter" "return false"
            , style dropStyle
            , onWithOptions
                "dragover"
                { preventDefault = True, stopPropagation = False }
                Json.Decode.value
                (\_ -> message address (IsDraggedOver True))
            , on "dragleave" Json.Decode.value (\_ -> message address (IsDraggedOver False))
            , on "drop" Json.Decode.value (\_ -> Debug.log "DROPPING" (message address IncDropCount))
            ]
            [ text "DROP ON ME, YE SCOUNDREL" ]
        , h1
            []
            [ text
                (if model.draggingOver == True then
                    "HOVERING OH WOW!"
                 else
                    "Nothing is happening."
                )
            ]
        , h1
            []
            [ text ("Drop count: " ++ (toString model.dropCount))
            ]
        ]


type Action
    = IsDraggedOver Bool
    | IncDropCount


update action model =
    case action of
        IsDraggedOver tf ->
            { model | draggingOver = tf }

        IncDropCount ->
            { model | draggingOver = False, dropCount = model.dropCount + 1 }


main =
    StartApp.Simple.start { model = model, view = render, update = update }
