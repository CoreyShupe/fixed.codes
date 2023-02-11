module Main exposing (..)

import Browser exposing (Document)
import Browser.Dom exposing (Viewport, getViewport)
import Browser.Events
import Browser.Navigation as Nav exposing (Key)
import GameOfLife exposing (GameOfLife, randomFill)
import Html exposing (a, i, text)
import Html.Attributes exposing (class, href, style)
import Json.Decode as Decode
import Platform.Sub exposing (batch)
import SystemRouter exposing (..)
import Task
import Time
import Tuple exposing (mapFirst)
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, map, oneOf, s)


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
    , gameOfLife : GameOfLife
    , pageState : PageState
    }


init : () -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    ( { pageState = resolveUrl url
      , gameOfLife = GameOfLife.init 0 0
      , key = key
      }
    , Task.perform GetViewport getViewport
    )


type alias ClickEvent =
    { pageX : Int, pageY : Int }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | Navigation SystemRouter.NavMsg
    | WidthHeight Int Int
    | Tick
    | GOL GameOfLife.GameOfLifeMsg
    | GetViewport Viewport
    | GenericClick ClickEvent


update :
    Msg
    -> Model
    -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key
                        (Url.toString url)
                    )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | pageState = resolveUrl url }, Cmd.none )

        Navigation (GotoRoute string) ->
            ( model, Nav.pushUrl model.key string )

        WidthHeight width height ->
            mapFirst
                (\gol -> { model | gameOfLife = gol })
                (randomFill
                    (GameOfLife.init
                        width
                        height
                    )
                    GOL
                )

        Tick ->
            ( { model
                | gameOfLife =
                    GameOfLife.calculateNextGeneration
                        model.gameOfLife
              }
            , Cmd.none
            )

        GOL message ->
            ( { model
                | gameOfLife =
                    GameOfLife.update
                        model.gameOfLife
                        message
              }
            , Cmd.none
            )

        GetViewport viewPort ->
            mapFirst
                (\gol -> { model | gameOfLife = gol })
                (GameOfLife.initRandom (round viewPort.viewport.width) (round viewPort.viewport.height) GOL)

        GenericClick clickEvent ->
            ( { model
                | gameOfLife =
                    GameOfLife.insert
                        clickEvent.pageX
                        clickEvent.pageY
                        model.gameOfLife
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    batch
        [ Browser.Events.onResize WidthHeight
        , Time.every 150 (\_ -> Tick)
        , Browser.Events.onClick
            (Decode.map
                GenericClick
                (Decode.map2 ClickEvent
                    (Decode.field "pageX" Decode.int)
                    (Decode.field "pageY" Decode.int)
                )
            )
        ]


view : Model -> Document Msg
view model =
    { title = "/fixed.codes/"
    , body =
        [ GameOfLife.view model.gameOfLife
        , case model.pageState of
            Home ->
                boxed [ style "position" "absolute" ]
                    [ navItem []
                        [ text "***" ]
                        [ text """
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit,
                        sed do eiusmod tempor incididunt ut labore et dolore magna
                        aliqua. Ut enim ad minim veniam, quis nostrud exercitation
                        ullamco laboris nisi ut aliquip ex ea commodo consequat.
                        Duis aute irure dolor in reprehenderit in voluptate velit
                        esse cillum dolore eu fugiat nulla pariatur. Excepteur sint
                        occaecat cupidatat non proident, sunt in culpa qui officia
                        deserunt mollit anim id est laborum.
                        """
                        ]
                        "/"
                        Navigation
                    , navItem []
                        [ text "***" ]
                        [ text """
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit,
                        sed do eiusmod tempor incididunt ut labore et dolore magna
                        aliqua. Ut enim ad minim veniam, quis nostrud exercitation
                        ullamco laboris nisi ut aliquip ex ea commodo consequat.
                        Duis aute irure dolor in reprehenderit in voluptate velit
                        esse cillum dolore eu fugiat nulla pariatur. Excepteur sint
                        occaecat cupidatat non proident, sunt in culpa qui officia
                        deserunt mollit anim id est laborum.
                        """
                        ]
                        "/"
                        Navigation
                    , navItem []
                        [ text "***" ]
                        [ text """
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit,
                        sed do eiusmod tempor incididunt ut labore et dolore magna
                        aliqua. Ut enim ad minim veniam, quis nostrud exercitation
                        ullamco laboris nisi ut aliquip ex ea commodo consequat.
                        Duis aute irure dolor in reprehenderit in voluptate velit
                        esse cillum dolore eu fugiat nulla pariatur. Excepteur sint
                        occaecat cupidatat non proident, sunt in culpa qui officia
                        deserunt mollit anim id est laborum.
                        """
                        ]
                        "/"
                        Navigation
                    ]
        , i
            [ class "fa-solid fa-square-github"
            , style "position" "absolute"
            , style "top" "-26px"
            , style "left" "3px"
            , style "cursor" "pointer"
            , style "font-size" "100px"
            , style "overflow" "hidden"
            , style "max-height" "78px"
            ]
            [ a
                [ href "https://github.com/CoreyShupe/fixed.codes"
                , style "width" "50px"
                , style "height" "78px"
                , style "position" "absolute"
                , style "top" "0px"
                , style "left" "0px"
                ]
                []
            ]
        ]
    }


type PageState
    = Home


routeParser : Parser (PageState -> a) a
routeParser =
    oneOf
        [ map Home (s "")
        ]


resolveUrl : Url -> PageState
resolveUrl url =
    Url.Parser.parse routeParser url
        |> Maybe.withDefault Home
