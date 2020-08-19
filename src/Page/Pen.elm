module Page.Pen exposing (view)

import Components.Heading as Heading
import Data.Pen exposing (Pen)
import Html.Styled exposing (Html, text)


view : Pen -> Html msg -> { title : String, body : List (Html msg) }
view pen viewForPage =
    { title = pen.name
    , body =
        [ Heading.view [] [ text pen.name ]
        , viewForPage
        ]
    }
