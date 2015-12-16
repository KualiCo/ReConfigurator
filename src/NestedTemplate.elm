module NestedTemplate (..) where

import Json.Decode as D exposing ((:=), Decoder, map, andThen, succeed)
import Json.Encode as Encode
import Native.ShortId


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
--{ elements: Dict Uuid TemplateElement
--, children: List Uuid
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
    | PanelEl TemplateElement
    | LayoutEl TemplateElement


type alias Layout =
    { id : String
    , type' : String
    , children : List TemplateElement
    }


type alias Gadget =
    { id : String
    , label : String
    , type' : String
    , json : String
    }


type alias Panel =
    { id : String
    , label : String
    , proposal : Bool
    , children : List TemplateElement
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


gadgetDecoder : Decoder Gadget
gadgetDecoder =
    D.object4
        (\label type' json id -> { label = label, type' = type', json = json, id = id })
        (withDefault ("label" := D.string) "No label set")
        ("type" := D.string)
        objectAsString
        (succeed (Native.ShortId.generate ()))


panelDecoder : Decoder (Panel TemplateElement)
panelDecoder =
    D.object4
        (\label proposal children id -> { label = label, proposal = proposal, children = children, id = id })
        (withDefault ("label" := D.string) "No label set")
        (withDefault ("proposal" := D.bool) False)
        ("children" := D.list tElementDecoder)
        (succeed (Native.ShortId.generate ()))


layoutElementDecoder : Decoder (Layout TemplateElement)
layoutElementDecoder =
    D.object3
        (\type' children id -> { type' = type', children = children, id = id })
        ("type" := D.string)
        ("children" := D.list tElementDecoder)
        (succeed (Native.ShortId.generate ()))


tElementDecoder : Decoder TemplateElement
tElementDecoder =
    ("type" := D.string)
        `andThen` (\type' ->
                    if type' == "Panel" then
                        (map PanelEl panelDecoder)
                    else if (type' == "Column" || type' == "Row") then
                        (map LayoutEl layoutElementDecoder)
                    else
                        (map GadgetEl gadgetDecoder)
                  )


templateDecoder : Decoder Template
templateDecoder =
    D.object3
        Template
        ("_meta" := D.value)
        ("id" := D.string)
        ("template" := (D.list tElementDecoder))


parse : String -> Result String Template
parse tString =
    D.decodeString
        templateDecoder
        tString
