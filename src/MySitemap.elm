module MySitemap exposing (build)

import Metadata exposing (Metadata(..))
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import Sitemap


build :
    String
    ->
        List
            { path : PagePath Pages.PathKey
            , frontmatter : Metadata
            , body : String
            }
    ->
        { path : List String
        , content : String
        }
build siteUrl siteMetadata =
    { path = [ "sitemap.xml" ]
    , content =
        Sitemap.build { siteUrl = siteUrl }
            (siteMetadata
                |> List.filter
                    (\page ->
                        case page.frontmatter of
                            -- Article articleData ->
                            --     not articleData.draft
                            _ ->
                                True
                    )
                |> List.map
                    (\page ->
                        { path = PagePath.toString page.path, lastMod = Nothing }
                    )
            )
    }
