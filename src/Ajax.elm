module Ajax (..) where

import Http exposing (get)
import NestedTemplate exposing (templateDecoder)
import Template exposing (Template, flattenTemplate)
import Task
import Actions exposing (..)
import Effects exposing (Effects)


type alias ApiInfo =
    { key : String
    , url : String
    }


fetchTemplate : (Template -> Action) -> (String -> Action) -> ApiInfo -> Effects Action
fetchTemplate okAction errAction apiInfo =
    Effects.task
        <| Task.map
            (\res ->
                case res of
                    Ok t ->
                        okAction t

                    Err e ->
                        errAction (toString e)
            )
        <| Task.map (Result.map flattenTemplate)
        <| Task.toResult
            (get templateDecoder (apiInfo.url ++ "/api/cm/config/course-template"))
