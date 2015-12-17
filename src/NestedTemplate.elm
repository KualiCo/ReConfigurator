module NestedTemplate (..) where

import Json.Decode as D exposing ((:=), Decoder, map, andThen, succeed, oneOf)
import Json.Decode.Extra exposing ((|:))
import Json.Encode as Encode
import ShortId


--
--This file is here because the data comes in from the server in a nested
--structure:
--{
--    type: "row",
--    children: [{type: "column", children: [...]}]
--}
--But I want to store and work with the data in a flat (denormalized) way,
--where all gadgets are identified by a uuid, and the children list contains
--ids instead of objects. Something like this:
--{ elements: Dict Id TemplateElement
--, children: List Id
--}
--I haven't yet been able to figure out how to achieve this in the same
--step as decoding. I'd like to be able to have the decoder return the flattened
--format directly, but as I experimented I found the code to be much less
--easily understandable. For now I've opted to have this intermediate type,
--a nested template, that then gets turned into a `Template` for use elsewhere
--in the app.
--


type ChildElements
    = ChildElements (List TemplateElement)


type alias TemplateElement =
    { id : String
    , type' : String
    , children : ChildElements
    , label : String
    , json : String
    }


type alias Template =
    { meta : D.Value
    , id : String
    , children : ChildElements
    }


children : { a | children : ChildElements } -> List TemplateElement
children recordWithChildren =
    let
        (ChildElements elems) = recordWithChildren.children
    in
        elems


objectAsString : Decoder String
objectAsString =
    D.customDecoder D.value (\json -> Ok (toString json))


withDefault : Decoder a -> a -> Decoder a
withDefault decoder default =
    D.oneOf [ decoder, D.succeed default ]


tElementDecoder : Decoder TemplateElement
tElementDecoder =
    ("type" := D.string)
        `andThen` (\type' ->
                    if type' == "Panel" || type' == "Row" || type' == "Column" then
                        succeed TemplateElement
                            |: (D.map (\_ -> (ShortId.generate ())) (succeed ""))
                            |: ("type" := D.string)
                            |: (D.map ChildElements ("children" := D.list tElementDecoder))
                            |: (withDefault ("label" := D.string) "No label set")
                            |: objectAsString
                    else
                        succeed TemplateElement
                            |: (D.map (\_ -> (ShortId.generate ())) (succeed ""))
                            |: ("type" := D.string)
                            |: (D.map ChildElements (succeed []))
                            |: (withDefault ("label" := D.string) "No label set")
                            |: objectAsString
                  )


templateDecoder : Decoder Template
templateDecoder =
    succeed Template
        |: ("_meta" := D.value)
        |: ("id" := D.string)
        |: (D.map ChildElements ("template" := (D.list tElementDecoder)))


emptyTemplate =
    { meta = Encode.null
    , template = []
    , id = ""
    }


parse : String -> Result String Template
parse tString =
    D.decodeString
        templateDecoder
        tString
