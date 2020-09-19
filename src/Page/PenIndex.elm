module Page.PenIndex exposing (view)

import Css exposing (listStyle, margin, none, padding, zero)
import Data.Pen exposing (Pen)
import Html.Styled exposing (Html, a, li, text, ul)
import Html.Styled.Attributes exposing (css, href)
import Metadata exposing (Metadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)


type alias PenEntry =
    ( PagePath Pages.PathKey, Pen )


view :
    List ( PagePath Pages.PathKey, Metadata )
    -> Html msg
view siteContent =
    ul [ css [ listStyle none, margin zero, padding zero ] ]
        (siteContent
            |> onlyPens
            |> List.sortWith penNameAscending
            |> List.map penSummary
            |> List.map (li [] << List.singleton)
        )


onlyPens :
    List ( PagePath Pages.PathKey, Metadata )
    -> List ( PagePath Pages.PathKey, Pen )
onlyPens =
    List.filterMap <|
        \( path, metadata ) ->
            case metadata of
                Metadata.Pen pen ->
                    Just ( path, pen )

                _ ->
                    Nothing


penNameAscending : PenEntry -> PenEntry -> Order
penNameAscending ( _, pen1 ) ( _, pen2 ) =
    compare pen1.name pen2.name


penSummary : PenEntry -> Html msg
penSummary ( path, pen ) =
    a [ href (PagePath.toString path) ]
        [ text pen.name ]
