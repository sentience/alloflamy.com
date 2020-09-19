module Pages.Directory.Util exposing (for)

import Pages exposing (PathKey)
import Pages.Directory
import Pages.PagePath exposing (PagePath)


for : PagePath PathKey -> Maybe (Pages.Directory.Directory Pages.PathKey Pages.Directory.WithIndex)
for page =
    -- manually maintained list of site directories to match the page path
    [ Pages.pages.pens.lamy.accent.directory
    ]
        |> List.filter (\directory -> Pages.Directory.includes directory page)
        |> List.head
