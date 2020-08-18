module Layout exposing (view)

import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font as Font
import Element.Region
import Html exposing (Html)
import Metadata exposing (Metadata)
import Pages
import Pages.Directory as Directory exposing (Directory)
import Pages.ImagePath as ImagePath
import Pages.PagePath as PagePath exposing (PagePath)


view :
    { title : String, body : List (Element msg) }
    ->
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        }
    -> { title : String, body : Html msg }
view document page =
    { title = document.title
    , body =
        Element.column
            [ Element.width Element.fill, Element.height Element.fill ]
            [ header page.path
            , Element.column
                [ Element.padding 30
                , Element.spacing 40
                , Element.Region.mainContent
                , Element.width (Element.fill |> Element.maximum 800)
                , Element.centerX
                ]
                document.body
            , footer
            ]
            |> Element.layout
                [ Element.width Element.fill
                , Font.size 20
                , Font.family [ Font.typeface "Roboto" ]
                , Font.color (Element.rgba255 0 0 0 0.8)
                ]
    }


header : PagePath Pages.PathKey -> Element msg
header currentPath =
    Element.column [ Element.width Element.fill ]
        [ Element.el
            [ Element.height (Element.px 4)
            , Element.width Element.fill
            , Element.Background.gradient
                { angle = 0.2
                , steps =
                    [ Element.rgb255 0 242 96
                    , Element.rgb255 5 117 230
                    ]
                }
            ]
            Element.none
        , Element.row
            [ Element.paddingXY 25 4
            , Element.spaceEvenly
            , Element.width Element.fill
            , Element.Region.navigation
            , Element.Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
            , Element.Border.color (Element.rgba255 40 80 40 0.4)
            ]
            [ Element.link []
                { url = "/"
                , label =
                    Element.row [ Font.size 30 ]
                        [ Element.text "All of "
                        , Element.image
                            [ Element.width (Element.px 124)
                            , Element.height (Element.px 28)
                            ]
                            { src = ImagePath.toString Pages.images.lamyBrandLogo, description = "Lamy" }
                        ]
                }
            , Element.row [ Element.spacing 15 ]
                [ highlightableLink currentPath (DirectoryLink Pages.pages.pens.directory) "Pens"
                , highlightableLink currentPath (PageLink Pages.pages.about) "About"
                ]
            ]
        ]


type Link
    = DirectoryLink (Directory Pages.PathKey Directory.WithIndex)
    | PageLink (PagePath Pages.PathKey)


highlightableLink :
    PagePath Pages.PathKey
    -> Link
    -> String
    -> Element msg
highlightableLink currentPath link displayName =
    let
        ( linkPath, isHighlighted ) =
            case link of
                DirectoryLink directory ->
                    ( Directory.indexPath directory
                    , Directory.includes directory currentPath
                    )

                PageLink pagePath ->
                    ( pagePath
                    , currentPath == pagePath
                    )
    in
    Element.link
        (if isHighlighted then
            [ Font.underline
            , Font.color (Element.rgb255 5 117 230)
            ]

         else
            []
        )
        { url = linkPath |> PagePath.toString
        , label = Element.text displayName
        }


footer : Element msg
footer =
    Element.column
        [ Element.Region.footer
        , Element.centerX
        , Element.alignBottom
        , Element.paddingXY 0 20
        , Font.size 12
        ]
        [ Element.text "LAMY is a trademark of C. Josef Lamy GmbH. This site is not affiliated with or endorsed by LAMY." ]
