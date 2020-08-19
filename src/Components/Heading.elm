module Components.Heading exposing (view)

import Css exposing (bold, fontFamilies, fontSize, fontWeight, px)
import Html.Styled exposing (Attribute, Html, h1, styled)


view : List (Attribute msg) -> List (Html msg) -> Html msg
view =
    styled h1
        [ fontWeight bold
        , fontFamilies [ "Raleway" ]
        , fontSize (px 36)
        ]
