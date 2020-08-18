module Page.Pen exposing (view)

import Data.Pen exposing (Pen)
import Element exposing (Element)
import Element.Font as Font
import Element.Region


view : Pen -> Element msg -> { title : String, body : List (Element msg) }
view pen viewForPage =
    { title = pen.name
    , body =
        [ Element.paragraph
            [ Font.bold
            , Font.family [ Font.typeface "Raleway" ]
            , Element.Region.heading 1
            , Font.size 36
            , Font.center
            ]
            [ Element.text pen.name ]
        , viewForPage
        ]
    }
