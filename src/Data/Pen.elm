module Data.Pen exposing (Pen, decode)

import Json.Decode as Decode exposing (Decoder)


type alias Pen =
    { name : String }


decode : Decoder Pen
decode =
    Decode.map Pen
        (Decode.field "name" Decode.string)
