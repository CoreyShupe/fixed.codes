module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Html exposing (button, div, li, p, section, text, ul)
import Html.Attributes exposing (class)
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
    {}


init : () -> Url -> Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( {}, Cmd.none )


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked _ ->
            ( model, Cmd.none )

        UrlChanged _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view _ =
    { title = "FiXed Codes"
    , body =
        [ section [ class "nav-box" ]
            [ div [ class "nav-item" ]
                [ button []
                    [ div []
                        [ text "Personal Projects"
                        ]
                    ]
                ]
            , div [ class "nav-item" ]
                [ button []
                    [ div []
                        [ text "Introduction"
                        ]
                    ]
                ]
            , div [ class "nav-item" ]
                [ button []
                    [ div []
                        [ text "Wiki Postings"
                        ]
                    ]
                ]
            , div [ class "nav-item" ]
                [ button []
                    [ div []
                        [ text "Useful Resources"
                        ]
                    ]
                ]
            ]
        ]
    }
