module NestedTemplate (..) where

import Json.Decode as D exposing ((:=), Decoder, map, andThen, succeed)
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
--I haven't yet been able to figure out how to do achieve this in the same
--step as decoding. I'd like to be able to have the decoder return the flattened
--format directly, but as I experimented I found the code to be much less
--easily understandable. For now I've opted to have this intermediate type,
--a nested template, that then gets turned into a `Template` for use elsewhere
--in the app.
--


type TemplateElement
    = GadgetEl Gadget
    | PanelEl Panel
    | LayoutEl Layout


type alias Layout =
    { type' : String
    , children : List TemplateElement
    , id : String
    }


type alias Gadget =
    { label : String
    , type' : String
    , json : String
    , id : String
    }


type alias Panel =
    { label : String
    , proposal : Bool
    , children : List TemplateElement
    , id : String
    }


type alias Template =
    { meta : D.Value
    , id : String
    , template : List TemplateElement
    }


objectAsString : Decoder String
objectAsString =
    D.customDecoder D.value (\json -> Ok (toString json))


withDefault : Decoder a -> a -> Decoder a
withDefault decoder default =
    D.oneOf [ decoder, D.succeed default ]


addId : (String -> a) -> a
addId constructor =
    constructor (ShortId.generate ())


gadgetDecoder : Decoder Gadget
gadgetDecoder =
    D.map addId
        <| succeed Gadget
        |: (withDefault ("label" := D.string) "No label set")
        |: ("type" := D.string)
        |: objectAsString


panelDecoder : Decoder Panel
panelDecoder =
    D.map addId
        <| succeed Panel
        |: (withDefault ("label" := D.string) "No label set")
        |: (withDefault ("proposal" := D.bool) False)
        |: ("children" := D.list tElementDecoder)


layoutElementDecoder : Decoder Layout
layoutElementDecoder =
    D.map addId
        <| succeed Layout
        |: ("type" := D.string)
        |: ("children" := D.list tElementDecoder)


tElementDecoder : Decoder TemplateElement
tElementDecoder =
    ("type" := D.string)
        `andThen` (\type' ->
                    if type' == "Panel" then
                        (D.map PanelEl panelDecoder)
                    else if (type' == "Column" || type' == "Row") then
                        (D.map LayoutEl layoutElementDecoder)
                    else
                        (D.map GadgetEl gadgetDecoder)
                  )


templateDecoder : Decoder Template
templateDecoder =
    D.object3
        Template
        ("_meta" := D.value)
        ("id" := D.string)
        ("template" := (D.list tElementDecoder))


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
