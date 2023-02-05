module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Nav exposing (Key)
import Html exposing (Html, button, div, section, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import RouterParser exposing (Route(..), resolveUrl)
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


type alias Model =
    { key : Key
    , currentPage : Route
    }


init : () -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    ( { currentPage = resolveUrl url
      , key = key
      }
    , Cmd.none
    )


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | GotoRoute String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | currentPage = resolveUrl url }, Cmd.none )

        GotoRoute string ->
            ( model, Nav.pushUrl model.key string )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view model =
    { title = "/fixed.codes/"
    , body =
        case model.currentPage of
            Home ->
                [ section [ class "nav-box" ]
                    [ navItem "Personal Projects" "/personal-projects"
                    , navItem "Introduction" "/introduction"
                    , navItem "Wiki Postings" "/wiki-postings"
                    , navItem "Useful Resources" "/useful-resources"
                    ]
                ]

            PersonalProjects ->
                [ placeholder "Personal Projects" ]

            Introduction ->
                [ placeholder "Introduction" ]

            WikiPostings ->
                [ placeholder "Wiki Postings" ]

            UsefulResources ->
                [ placeholder "Useful Resources" ]
    }


placeholder : String -> Html Msg
placeholder name =
    div
        [ style "color" "white"
        , style "font-size" "xx-large"
        ]
        [ text name ]


navItem : String -> String -> Html Msg
navItem friendlyName link =
    div [ class "nav-item" ]
        [ button [ onClick (GotoRoute link) ]
            [ div []
                [ text friendlyName
                ]
            ]
        ]
