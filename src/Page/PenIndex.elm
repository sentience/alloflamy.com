module Page.PenIndex exposing (view)

import Css exposing (listStyle, margin, none, padding, zero)
import Data.Pen exposing (Pen)
import Html.Styled exposing (Html, a, div, h1, li, p, text, ul)
import Html.Styled.Attributes exposing (css, href)
import List.Extra
import Metadata exposing (Metadata)
import Pages
import Pages.Directory as Directory
import Pages.PagePath as PagePath exposing (PagePath)


type alias PenEntry =
    ( PagePath Pages.PathKey, Pen )


type Brand
    = LAMY
    | Artus


type alias BrandInfo =
    { name : String
    , description : String
    , order : Int
    }


view :
    List ( PagePath Pages.PathKey, Metadata )
    -> Html msg
view siteContent =
    div []
        (siteContent
            |> onlyPens
            |> List.sortWith penNameAscending
            |> List.Extra.gatherEqualsBy (Tuple.first >> pathToBrand)
            |> List.sortBy (Tuple.first >> Tuple.first >> pathToBrand >> brandInfo >> .order)
            |> List.map viewBrandList
        )


viewBrandList : ( PenEntry, List PenEntry ) -> Html msg
viewBrandList ( penEntry, morePenEntries ) =
    let
        { name, description } =
            penEntry |> Tuple.first |> pathToBrand |> brandInfo
    in
    div []
        [ h1 [] [ text name ]
        , p [] [ text description ]
        , ul [ css [ listStyle none, margin zero, padding zero ] ]
            ((penEntry :: morePenEntries)
                |> List.map penSummary
                |> List.map (li [] << List.singleton)
            )
        ]


pathToBrand : PagePath Pages.PathKey -> Brand
pathToBrand path =
    if Directory.includes Pages.pages.pens.lamy.directory path then
        LAMY

    else
        Artus


brandInfo : Brand -> BrandInfo
brandInfo brand =
    case brand of
        LAMY ->
            BrandInfo "LAMY"
                ("""
                The famous manufacturer of writing instruments based in
                Heidelberg, Germany.
                """
                    |> String.words
                    |> String.join " "
                )
                0

        Artus ->
            BrandInfo "Artus"
                ("""
                Prior to 1952, from its founding in 1930, the company known as
                Orthos Füllfederhalter-Fabrik (Orthos fountain pen factory)
                released pens under the names Artus and Orthos.
                """
                    |> String.words
                    |> String.join " "
                )
                1


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
