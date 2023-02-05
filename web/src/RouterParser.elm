module RouterParser exposing (..)

import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, map, oneOf, s)


type Route
    = Home
    | PersonalProjects
    | Introduction
    | WikiPostings
    | UsefulResources


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Home (s "")
        , map PersonalProjects (s "personal-projects")
        , map Introduction (s "introduction")
        , map WikiPostings (s "wiki-postings")
        , map UsefulResources (s "useful-resources")
        ]


resolveUrl : Url -> Route
resolveUrl url =
    Url.Parser.parse routeParser url
        |> Maybe.withDefault Home
