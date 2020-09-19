module Main exposing (main)

import Color
import Feed
import Head
import Head.Seo as Seo
import Html
import Html.Styled exposing (Html)
import Json.Decode
import Layout
import Markdown.Block as Block
import Markdown.Parser
import Markdown.Renderer exposing (Renderer)
import Metadata exposing (Metadata)
import MySitemap
import Page.Pen
import Page.PenIndex
import Pages exposing (images, pages)
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.PagePath exposing (PagePath)
import Pages.Platform
import Pages.StaticHttp as StaticHttp


manifest : Manifest.Config Pages.PathKey
manifest =
    { backgroundColor = Just Color.white
    , categories = [ Pages.Manifest.Category.education ]
    , displayMode = Manifest.Standalone
    , orientation = Manifest.Portrait
    , description = siteTagline
    , iarcRatingId = Nothing
    , name = "All of LAMY"
    , themeColor = Just Color.white
    , startUrl = pages.index
    , shortName = Just "All of LAMY"
    , sourceIcon = images.iconPng
    }



-- the intellij-elm plugin doesn't support type aliases for Programs so we need to use this line
-- main : Platform.Program Pages.Platform.Flags (Pages.Platform.Model Model Msg Metadata Rendered) (Pages.Platform.Msg Msg Metadata Rendered)


main : Pages.Platform.Program Model Msg Metadata (Html Msg)
main =
    Pages.Platform.init
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ markdownDocument Block.H2 ]
        , manifest = manifest
        , canonicalSiteUrl = canonicalSiteUrl
        , onPageChange = Nothing
        , internals = Pages.internals
        }
        |> Pages.Platform.withFileGenerator generateFiles
        |> Pages.Platform.toProgram


generateFiles :
    List
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        , body : String
        }
    ->
        StaticHttp.Request
            (List
                (Result String
                    { path : List String
                    , content : String
                    }
                )
            )
generateFiles siteMetadata =
    StaticHttp.succeed
        [ Feed.fileToGenerate { siteTagline = siteTagline, siteUrl = canonicalSiteUrl } siteMetadata |> Ok
        , MySitemap.build canonicalSiteUrl siteMetadata |> Ok
        ]


markdownDocument : Block.HeadingLevel -> { extension : String, metadata : Json.Decode.Decoder Metadata, body : String -> Result error (Html msg) }
markdownDocument minHeadingLevel =
    { extension = "md"
    , metadata = Metadata.decoder
    , body =
        \markdownBody ->
            -- Html.div [] [ Markdown.toHtml [] markdownBody ]
            Markdown.Parser.parse markdownBody
                |> Result.withDefault []
                |> Markdown.Renderer.render (Markdown.Renderer.defaultHtmlRenderer |> withMinHeadingLevel minHeadingLevel)
                |> Result.withDefault [ Html.text "" ]
                |> Html.div []
                |> Html.Styled.fromUnstyled
                |> Ok
    }


withMinHeadingLevel : Block.HeadingLevel -> Renderer (Html.Html msg) -> Renderer (Html.Html msg)
withMinHeadingLevel minHeadingLevel renderer =
    { renderer
        | heading =
            \{ level, children } ->
                case minHeadingLevel of
                    Block.H1 ->
                        case level of
                            Block.H1 ->
                                Html.h1 [] children

                            Block.H2 ->
                                Html.h2 [] children

                            Block.H3 ->
                                Html.h3 [] children

                            Block.H4 ->
                                Html.h4 [] children

                            Block.H5 ->
                                Html.h5 [] children

                            Block.H6 ->
                                Html.h6 [] children

                    Block.H2 ->
                        case level of
                            Block.H1 ->
                                Html.h2 [] children

                            Block.H2 ->
                                Html.h3 [] children

                            Block.H3 ->
                                Html.h4 [] children

                            Block.H4 ->
                                Html.h5 [] children

                            Block.H5 ->
                                Html.h6 [] children

                            _ ->
                                Html.div [] children

                    Block.H3 ->
                        case level of
                            Block.H1 ->
                                Html.h3 [] children

                            Block.H2 ->
                                Html.h4 [] children

                            Block.H3 ->
                                Html.h5 [] children

                            Block.H4 ->
                                Html.h6 [] children

                            _ ->
                                Html.div [] children

                    Block.H4 ->
                        case level of
                            Block.H1 ->
                                Html.h4 [] children

                            Block.H2 ->
                                Html.h5 [] children

                            Block.H3 ->
                                Html.h6 [] children

                            _ ->
                                Html.div [] children

                    Block.H5 ->
                        case level of
                            Block.H1 ->
                                Html.h5 [] children

                            Block.H2 ->
                                Html.h6 [] children

                            _ ->
                                Html.div [] children

                    Block.H6 ->
                        case level of
                            Block.H1 ->
                                Html.h6 [] children

                            _ ->
                                Html.div [] children
    }


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( Model, Cmd.none )


type alias Msg =
    ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        () ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view :
    List ( PagePath Pages.PathKey, Metadata )
    ->
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        }
    ->
        StaticHttp.Request
            { view : Model -> Html Msg -> { title : String, body : Html.Html Msg }
            , head : List (Head.Tag Pages.PathKey)
            }
view siteMetadata page =
    StaticHttp.succeed
        { view =
            \model viewForPage ->
                Layout.view (pageView model siteMetadata page viewForPage) page
        , head = head page.frontmatter
        }


pageView :
    Model
    -> List ( PagePath Pages.PathKey, Metadata )
    -> { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> Html Msg
    -> { title : String, body : List (Html Msg) }
pageView _ siteMetadata page viewForPage =
    case page.frontmatter of
        Metadata.Page title ->
            { title = title
            , body =
                [ viewForPage
                ]
            }

        Metadata.PenIndex ->
            { title = "LAMY pens"
            , body =
                [ Page.PenIndex.view siteMetadata
                ]
            }

        Metadata.Pen pen ->
            Page.Pen.view siteMetadata page.path pen viewForPage

        Metadata.Accessory ->
            { title = "TODO", body = [] }

        Metadata.Model _ ->
            { title = "TODO", body = [] }


commonHeadTags : List (Head.Tag Pages.PathKey)
commonHeadTags =
    [ Head.rssLink "/blog/feed.xml"
    , Head.sitemapLink "/sitemap.xml"
    ]



{- Read more about the metadata specs:

   <https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards>
   <https://htmlhead.dev>
   <https://html.spec.whatwg.org/multipage/semantics.html#standard-metadata-names>
   <https://ogp.me/>
-}


head : Metadata -> List (Head.Tag Pages.PathKey)
head metadata =
    commonHeadTags
        ++ (case metadata of
                Metadata.Page title ->
                    Seo.summaryLarge
                        { canonicalUrlOverride = Nothing
                        , siteName = "All of LAMY"
                        , image =
                            { url = images.iconPng
                            , alt = "elm-pages logo"
                            , dimensions = Nothing
                            , mimeType = Nothing
                            }
                        , description = siteTagline
                        , locale = Nothing
                        , title = title
                        }
                        |> Seo.website

                Metadata.Pen _ ->
                    []

                Metadata.PenIndex ->
                    []

                Metadata.Accessory ->
                    []

                Metadata.Model _ ->
                    []
           )


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://alloflamy.com"


siteTagline : String
siteTagline =
    "An unofficial history of LAMY fountain pens"
