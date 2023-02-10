module GameOfLife exposing (..)

import Canvas exposing (..)
import Canvas.Settings exposing (fill)
import Canvas.Settings.Text
import Color exposing (Color)
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes exposing (id, style)
import List
import Random
import String exposing (fromInt)


pixelsPerSquare : Float
pixelsPerSquare =
    8


placementChance : Float
placementChance =
    0.12


cellColor : Color
cellColor =
    Color.rgba 234 234 234 1


type alias GameOfLife =
    { populatedCells : List ( Int, Int )
    , height : Int
    , width : Int
    , cellHeight : Int
    , cellWidth : Int
    , generation : Int
    }


insert : Int -> Int -> GameOfLife -> GameOfLife
insert pageX pageY model =
    if
        pageX
            >= 0
            && pageY
            >= 0
            && pageY
            < model.height
            && pageX
            < model.width
    then
        let
            cellX =
                floor (toFloat pageX / pixelsPerSquare)

            cellY =
                floor (toFloat pageY / pixelsPerSquare)
        in
        if List.member ( cellX, cellY ) model.populatedCells then
            model

        else
            { model
                | populatedCells =
                    ( cellX, cellY )
                        :: model.populatedCells
            }

    else
        model


initRandom : Int -> Int -> (GameOfLifeMsg -> msg) -> ( GameOfLife, Cmd msg )
initRandom width height mapper =
    let
        newModel =
            init width height
    in
    randomFill newModel mapper


init : Int -> Int -> GameOfLife
init width height =
    { populatedCells = []
    , height = bind height - round pixelsPerSquare
    , width = bind width
    , cellHeight =
        round
            (toFloat
                (bind height - round pixelsPerSquare)
                / pixelsPerSquare
            )
    , cellWidth =
        round
            (toFloat
                (bind width)
                / pixelsPerSquare
            )
    , generation = 0
    }


bind : Int -> Int
bind v =
    v - modBy (round pixelsPerSquare) v


type GameOfLifeMsg
    = RandomFill (List Float)


randomFill : GameOfLife -> (GameOfLifeMsg -> msg) -> ( GameOfLife, Cmd msg )
randomFill model mapper =
    ( model
    , Random.generate
        (mapper << RandomFill)
        (Random.list
            (model.cellWidth * model.cellHeight)
            (Random.float 0 1)
        )
    )


update : GameOfLife -> GameOfLifeMsg -> GameOfLife
update model msg =
    if toFloat model.width < pixelsPerSquare || toFloat model.height < pixelsPerSquare then
        model

    else
        case msg of
            RandomFill randoms ->
                let
                    firstMap =
                        List.indexedMap
                            (\idx v -> ( idx, v ))
                            randoms

                    chosen =
                        List.filter
                            (\( _, x ) -> x < placementChance)
                            firstMap

                    mapped =
                        List.map
                            (\( idx, _ ) ->
                                ( modBy model.cellWidth idx
                                , floor
                                    (toFloat idx
                                        / toFloat model.cellWidth
                                    )
                                )
                            )
                            chosen
                in
                { model | populatedCells = mapped }


view : GameOfLife -> Html msg
view model =
    Canvas.toHtml ( model.width, model.height )
        [ id "game_of_life"
        , style "position" "absolute"
        , style "top" "0"
        , style "left" "0"
        , style "z-index" "-2"
        ]
        [ clear ( 0, 0 ) (toFloat model.width) (toFloat model.height)
        , shapes [ fill cellColor ] (buildTileShapes model.populatedCells)
        , text
            [ Canvas.Settings.stroke cellColor, Canvas.Settings.Text.font { size = 18, family = "monospace" } ]
            ( 10, 40 )
            ("Generation: " ++ fromInt model.generation)
        , text
            [ Canvas.Settings.stroke cellColor, Canvas.Settings.Text.font { size = 18, family = "monospace" } ]
            ( 10, 60 )
            ("Population: " ++ fromInt (List.length model.populatedCells))
        ]


buildTileShapes : List ( Int, Int ) -> List Shape
buildTileShapes cells =
    List.map
        (\( x, y ) ->
            rect
                ( toFloat x * pixelsPerSquare
                , toFloat y * pixelsPerSquare
                )
                pixelsPerSquare
                pixelsPerSquare
        )
        (List.filter
            (\( x, y ) -> (x > 23 && y < 9) || y >= 9)
            cells
        )


calculateNextGeneration : GameOfLife -> GameOfLife
calculateNextGeneration model =
    let
        nextGeneration =
            Dict.foldl
                (\( x, y ) state acc ->
                    case state of
                        Seen 2 ->
                            if
                                List.member
                                    ( x, y )
                                    model.populatedCells
                            then
                                ( x, y ) :: acc

                            else
                                acc

                        Seen 3 ->
                            ( x, y ) :: acc

                        Unseen 3 ->
                            ( x, y ) :: acc

                        _ ->
                            acc
                )
                []
                (calculateGenerationalNeighbors
                    model.width
                    model.height
                    model.populatedCells
                )
    in
    { model | populatedCells = nextGeneration, generation = model.generation + 1 }


type CellState
    = Seen Int
    | Unseen Int


calculateGenerationalNeighbors :
    Int
    -> Int
    -> List ( Int, Int )
    -> Dict ( Int, Int ) CellState
calculateGenerationalNeighbors width height cells =
    List.foldr
        (\cell acc ->
            processNeighborDictionary
                cell
                width
                height
                acc
        )
        Dict.empty
        cells


processNeighborDictionary :
    ( Int, Int )
    -> Int
    -> Int
    -> Dict ( Int, Int ) CellState
    -> Dict ( Int, Int ) CellState
processNeighborDictionary cell width height currentDict =
    let
        ( x, y ) =
            cell

        neighbors =
            List.filter
                (\( cx, cy ) ->
                    cx
                        >= 0
                        && cy
                        >= 0
                        && ((cy + 1) * round pixelsPerSquare)
                        < height
                        && ((cx + 1) * round pixelsPerSquare)
                        < width
                )
                (List.map
                    (\( ox, oy ) -> ( x + ox, y + oy ))
                    [ ( -1, -1 )
                    , ( -1, 0 )
                    , ( -1, 1 )
                    , ( 0, -1 )
                    , ( 0, 1 )
                    , ( 1, -1 )
                    , ( 1, 0 )
                    , ( 1, 1 )
                    ]
                )

        usable =
            cellUpdate
                (\currentState ->
                    case currentState of
                        Unseen 0 ->
                            Seen 0

                        Unseen count ->
                            Seen count

                        Seen count ->
                            Seen count
                )
                cell
                currentDict

        neighborDict =
            List.foldr
                (\neighbor dict ->
                    cellUpdate
                        simplePlusOne
                        neighbor
                        dict
                )
                usable
                neighbors
    in
    neighborDict


simplePlusOne : CellState -> CellState
simplePlusOne state =
    case state of
        Seen count ->
            Seen (1 + count)

        Unseen count ->
            Unseen (1 + count)


cellUpdate :
    (CellState -> CellState)
    -> ( Int, Int )
    -> Dict ( Int, Int ) CellState
    -> Dict ( Int, Int ) CellState
cellUpdate method cell dict =
    Dict.update cell
        (\currentState ->
            Just
                (case currentState of
                    Just value ->
                        method value

                    Nothing ->
                        method (Unseen 0)
                )
        )
        dict
