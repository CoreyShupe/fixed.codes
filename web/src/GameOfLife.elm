module GameOfLife exposing (..)

import Canvas exposing (..)
import Canvas.Settings exposing (fill)
import Color
import Dict exposing (Dict)
import Html exposing (Html)
import List
import Random


pixelsPerSquare : Float
pixelsPerSquare =
    8


type alias GameOfLife =
    { populatedCells : List ( Int, Int )
    , height : Int
    , width : Int
    , cellHeight : Int
    , cellWidth : Int
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
                            (\( _, x ) -> x < 0.12)
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


viewGameOfLife : GameOfLife -> Html msg
viewGameOfLife model =
    Canvas.toHtml
        ( model.width, model.height )
        []
        [ clear ( 0, 0 )
            (toFloat model.width)
            (toFloat model.height)
        , shapes
            [ fill (Color.rgba 234 234 234 255)
            ]
            (buildTileShapes model.populatedCells)
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
        cells


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
    { model | populatedCells = nextGeneration }


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
