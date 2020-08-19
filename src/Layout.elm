module Layout exposing (view)

import Css exposing (alignItems, alignSelf, auto, backgroundImage, baseline, before, block, borderBottom3, borderBox, boxSizing, center, color, column, display, displayFlex, flexDirection, fontFamilies, fontSize, height, hex, hsl, inherit, justifyContent, linearGradient2, link, margin, margin2, marginLeft, marginRight, marginTop, maxWidth, none, padding2, paddingBottom, pct, property, px, rgb, solid, spaceBetween, stop, stretch, textAlign, textDecoration, textTransform, toRight, underline, uppercase, visited, width, zero)
import Css.Global exposing (body, descendants, each, everything, global, html, typeSelector)
import Html
import Html.Styled exposing (Html, a, div, img, main_, nav, text, toUnstyled)
import Html.Styled.Attributes exposing (alt, css, href, src)
import Metadata exposing (Metadata)
import Pages
import Pages.Directory as Directory exposing (Directory)
import Pages.ImagePath as ImagePath
import Pages.PagePath as PagePath exposing (PagePath)


view :
    { title : String, body : List (Html msg) }
    ->
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        }
    -> { title : String, body : Html.Html msg }
view document page =
    { title = document.title
    , body =
        div
            [ css
                [ displayFlex
                , flexDirection column
                , height (pct 100)
                , width (pct 100)
                , alignItems stretch
                , fontSize (px 20)
                , fontFamilies [ "Roboto" ]
                , color (hsl 0 0 0.2)
                ]
            ]
            [ global
                [ each [ body, html ]
                    [ margin zero, height (pct 100) ]
                , typeSelector "nav"
                    [ descendants
                        [ everything
                            (List.map
                                (\selector ->
                                    selector
                                        [ color inherit
                                        , textDecoration none
                                        ]
                                )
                                [ link
                                , visited
                                ]
                            )
                        ]
                    ]
                ]
            , header page.path
            , main_
                [ css
                    [ width (pct 100)
                    , maxWidth (px 800)
                    , alignSelf center
                    , padding2 zero (px 20)
                    , boxSizing borderBox
                    ]
                ]
                document.body
            , footer
            ]
            |> toUnstyled
    }


header : PagePath Pages.PathKey -> Html msg
header currentPath =
    nav
        [ css
            [ before
                [ display block
                , width (pct 100)
                , height (px 4)
                , backgroundImage
                    (linearGradient2 toRight
                        -- Safari Candy Aquamarine
                        (stop <| hex "#479F9B")
                        -- Safari Candy Mango
                        (stop <| hex "#ECAC55")
                        -- Safari Candy Violet
                        [ stop <| hex "#454688" ]
                    )
                , property "content" "''"
                ]
            ]
        ]
        [ div
            [ css
                [ displayFlex
                , justifyContent spaceBetween
                , alignItems baseline
                , width (pct 100)
                , borderBottom3 (px 1) solid (hex "#ADB8AB")
                , padding2 (px 5) (px 20)
                , boxSizing borderBox
                ]
            ]
            [ a
                [ href "/"
                , css
                    [ fontSize (px 30)
                    , marginRight auto
                    ]
                ]
                [ text "All of "
                , let
                    imgPath =
                        Pages.images.lamyBrandLogo

                    dimensions =
                        ImagePath.dimensions imgPath
                            |> Maybe.withDefault (ImagePath.Dimensions 0 0)
                  in
                  img
                    [ src (ImagePath.toString imgPath)
                    , Html.Styled.Attributes.width dimensions.width
                    , Html.Styled.Attributes.height dimensions.height
                    , alt "Lamy"
                    , css [ textTransform uppercase ]
                    ]
                    []
                ]
            , highlightableLink currentPath (DirectoryLink Pages.pages.pens.directory) "Pens"
            , highlightableLink currentPath (PageLink Pages.pages.about) "About"
            ]
        ]


type Link
    = DirectoryLink (Directory Pages.PathKey Directory.WithIndex)
    | PageLink (PagePath Pages.PathKey)


highlightableLink :
    PagePath Pages.PathKey
    -> Link
    -> String
    -> Html msg
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
    a
        [ href (linkPath |> PagePath.toString)
        , css
            -- to override global link style
            ([ Css.link, Css.visited ]
                |> List.map
                    (\selector ->
                        selector
                            (marginLeft (px 15)
                                :: (if isHighlighted then
                                        [ textDecoration underline ]

                                    else
                                        [ textDecoration none ]
                                   )
                            )
                    )
            )
        ]
        [ text displayName ]


footer : Html msg
footer =
    Html.Styled.footer
        [ css
            [ marginTop auto
            , textAlign center
            , paddingBottom (px 20)
            , fontSize (px 12)
            ]
        ]
        [ text "LAMY is a trademark of C. Josef Lamy GmbH. This site is not affiliated with or endorsed by LAMY." ]
