module PenIndex exposing (view)

import Data.Pen exposing (Pen)
import Element exposing (Element)
import Metadata exposing (Metadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)


type alias PenEntry =
    ( PagePath Pages.PathKey, Pen )


view :
    List ( PagePath Pages.PathKey, Metadata )
    -> Element msg
view siteContent =
    Element.column [ Element.spacing 20 ]
        (siteContent
            |> onlyPens
            |> List.sortWith penNameAscending
            |> List.map penSummary
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


penSummary : PenEntry -> Element msg
penSummary ( path, pen ) =
    Element.link [ Element.width Element.fill ]
        { url = PagePath.toString path, label = Element.text pen.name }
