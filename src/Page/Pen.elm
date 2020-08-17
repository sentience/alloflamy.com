module Page.Pen exposing (view)

import Data.Pen exposing (Pen)
import Element exposing (Element)
import Palette


view : Pen -> Element msg -> { title : String, body : List (Element msg) }
view pen viewForPage =
    { title = pen.name
    , body =
        [ Palette.blogHeading pen.name
        , viewForPage
        ]
    }
