module SystemRouter exposing (..)

import Html exposing (Attribute, Html, button, div, span, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)



--- This module simply exposes base "functions" that are used around the project
--- Eventually this should be replaced with something more specific to the project


type NavMsg
    = GotoRoute String


boxed : List (Attribute msg) -> List (Html msg) -> Html msg
boxed attrs children =
    Html.section
        (List.concat
            [ [ Html.Attributes.class "nav-box" ], attrs ]
        )
        children


navItem :
    List (Attribute msg)
    -> List (Html msg)
    -> String
    -> (NavMsg -> msg)
    -> Html msg
navItem attrs inner link messageMapper =
    div
        (List.concat
            [ [ class "nav-item" ], attrs ]
        )
        [ button [ onClick (messageMapper (GotoRoute link)) ] [ div [] inner ]
        ]


home : List (Attribute msg) -> (NavMsg -> msg) -> Html msg
home attrs mapper =
    div
        (List.concat
            [ [ class "nav-item" ], attrs ]
        )
        [ button [ onClick (mapper (GotoRoute "/")), style "margin" "12px 12px" ]
            [ div [ style "font-size" "20px" ]
                [ span [ class "material-icons" ] [ text "home" ]
                , span [] [ text "Home" ]
                ]
            ]
        ]


back : List (Attribute msg) -> (NavMsg -> msg) -> String -> Html msg
back attrs mapper to =
    div
        (List.concat
            [ [ class "nav-item" ], attrs ]
        )
        [ button [ onClick (mapper (GotoRoute to)), style "margin" "12px 12px" ]
            [ div [ style "font-size" "20px" ]
                [ span [ class "material-icons" ] [ text "navigate_before" ]
                , span [] [ text "Go Back" ]
                ]
            ]
        ]