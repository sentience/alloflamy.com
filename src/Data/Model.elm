module Data.Model exposing (Availability(..), Model, decode)

import Json.Decode exposing (Decoder, field, int, map, map2, map3, maybe, oneOf, string)


type alias Model =
    { code : Maybe String
    , finish : String
    , availability : Maybe Availability
    }


type Availability
    = From Int
    | To Int
    | FromTo Int Int


decode : Decoder Model
decode =
    map3 Model
        (field "code" string |> maybe)
        (field "finish" string)
        (decodeAvailability |> maybe)


decodeAvailability : Decoder Availability
decodeAvailability =
    oneOf
        [ map2 FromTo
            (field "year-from" int)
            (field "year-to" int)
        , map From (field "year-from" int)
        , map To (field "year-to" int)
        ]
