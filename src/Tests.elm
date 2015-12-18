module Tests (..) where

import ElmTest exposing (..)
import Template exposing (emptyTemplate)
import Fixtures exposing (templateString)
import String


all : Test
all =
    suite
        "A template"
        [ test
            "Comparing empty templates"
            (assertEqual emptyTemplate emptyTemplate)
          --, test
          --    "should be parsed and stringified without data loss"
          --    (assertEqual
          --        templateString
          --        (Template.toString (Template.fromString templateString))
          --    )
        ]
