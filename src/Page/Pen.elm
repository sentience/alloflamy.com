module Page.Pen exposing (view)

import Components.Heading as Heading
import Css exposing (float, right)
import Data.Model exposing (Availability(..), Model)
import Data.Pen exposing (Pen)
import Html.Styled exposing (Html, caption, table, tbody, td, text, th, thead, tr)
import Html.Styled.Attributes exposing (css, scope)
import Metadata exposing (Metadata)
import Pages
import Pages.Directory as Directory
import Pages.Directory.Util as DirectoryUtil
import Pages.PagePath exposing (PagePath)


view : List ( PagePath Pages.PathKey, Metadata ) -> PagePath Pages.PathKey -> Pen -> Html msg -> { title : String, body : List (Html msg) }
view siteContent path pen viewForPage =
    { title = pen.name
    , body =
        [ Heading.view [] [ text pen.name ]
        , viewModels siteContent path
        , viewForPage
        ]
    }


viewModels : List ( PagePath Pages.PathKey, Metadata ) -> PagePath Pages.PathKey -> Html msg
viewModels siteContent path =
    let
        models : List ( PagePath Pages.PathKey, Model )
        models =
            siteContent
                |> List.filter (Tuple.first >> isDescendant path)
                |> onlyModels
                |> List.sortWith availabilityAscending

        availabilityAscending : ( a, { model | availability : Maybe Availability } ) -> ( a, { model | availability : Maybe Availability } ) -> Order
        availabilityAscending ( _, model1 ) ( _, model2 ) =
            let
                fromYear : Maybe Availability -> Int
                fromYear maybeAvailability =
                    case maybeAvailability of
                        Just (FromTo from _) ->
                            from

                        Just (From from) ->
                            from

                        _ ->
                            0

                toYear : Maybe Availability -> Int
                toYear maybeAvailability =
                    case maybeAvailability of
                        Just (FromTo _ to) ->
                            to

                        Just (To to) ->
                            to

                        _ ->
                            10000
            in
            case compare (fromYear model1.availability) (fromYear model2.availability) of
                EQ ->
                    compare (toYear model1.availability) (toYear model2.availability)

                notEQ ->
                    notEQ
    in
    case models of
        [] ->
            text ""

        _ ->
            table [ css [ float right ] ]
                [ caption [] [ text "models" ]
                , thead []
                    [ tr []
                        [ th [] []
                        , th [ scope "col" ] [ text "finish" ]
                        ]
                    ]
                , tbody [] (List.map viewModel models)
                ]


isDescendant : PagePath Pages.PathKey -> PagePath Pages.PathKey -> Bool
isDescendant rootPath candidatePath =
    DirectoryUtil.for rootPath
        |> Maybe.map (\dir -> Directory.includes dir candidatePath)
        |> Maybe.withDefault False


onlyModels :
    List ( PagePath Pages.PathKey, Metadata )
    -> List ( PagePath Pages.PathKey, Model )
onlyModels =
    List.filterMap <|
        \( path, metadata ) ->
            case metadata of
                Metadata.Model model ->
                    Just ( path, model )

                _ ->
                    Nothing


viewModel : ( PagePath Pages.PathKey, Model ) -> Html msg
viewModel ( path, model ) =
    tr []
        [ model.availability |> Maybe.map (\availability -> td [] [ viewAvailability availability ]) |> Maybe.withDefault (text "")
        , td []
            [ text model.finish
            , text (model.code |> Maybe.map (\code -> " (" ++ code ++ ")") |> Maybe.withDefault "")
            ]
        ]


viewAvailability : Availability -> Html msg
viewAvailability availability =
    case availability of
        From from ->
            text (String.fromInt from ++ "–")

        To to ->
            text ("–" ++ String.fromInt to)

        FromTo from to ->
            if from == to then
                text (String.fromInt from)

            else
                text (String.fromInt from ++ "–" ++ String.fromInt to)
