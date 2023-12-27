module day16mod
FILENAME = "src/inputs/day16.txt"
export day16
import ..tools: file_to_string, emptyfilter, intparse_all
using StaticArrays
using Match
using DataStructures

function day16()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

# FIXME this is reused often, it could live in tools
@enum DIRECTION NORTH=1 SOUTH EAST WEST

# elem can be '|', '-', '.', '/', '\', '#'
# The tile kind '#' is used for the border to absorb all light
struct Tile
    elem::Char
    directions::MVector{4, Bool}
end

function Tile(c::Char)
    Tile(c, MVector{4, Bool}(false, false, false, false))
end

struct Grid
    tiles::Matrix{Tile}
end

function Grid(str::T) where T <: AbstractString
    n_columns = first(findfirst('\n', str)) - 1
    lines = split(str, '\n') |> emptyfilter
    n_rows = length(lines)
    tiles = Matrix{Tile}(undef, n_rows, n_columns)
    for (r,line) in enumerate(lines)
        tiles[r, :] = [Tile(c) for c in line]
    end
    Grid(tiles)
end

function Base.size(g::Grid)
    return size(g.tiles)
end

# Index into g.tiles but return '#'-tile if the index is out of bounds
function Base.getindex(g::Grid, r, c)
    n_rows, n_cols = size(g)
    if r < 1 || c < 1 || r > n_rows || c > n_cols
        return Tile('#', MVector{4, Bool}(false, false, false, false))
    end

    return g.tiles[r, c]
end

function rc_after_move(r, c, dir)
    @match dir begin
        $NORTH => (r - 1, c)
        $SOUTH => (r + 1, c)
        $EAST => (r, c + 1)
        $WEST => (r, c - 1)
    end
end

function compute_next_direction(tile, moving_dir)::Vector{DIRECTION}
    next_directions = @match (tile.elem, moving_dir) begin
        ('#', _) => []
        ('.',  d) => [d]
        ('-', $EAST) => [EAST]
        ('-', $WEST) => [WEST]
        ('-', $SOUTH) | ('-', $NORTH) => [WEST, EAST]
        ('|', $NORTH) => [NORTH]
        ('|', $SOUTH) => [SOUTH]
        ('|', $WEST) | ('|', $EAST) => [NORTH, SOUTH]
        ('/', $NORTH) => [EAST]
        ('/', $SOUTH) => [WEST]
        ('/', $EAST) => [NORTH]
        ('/', $WEST) => [SOUTH]
        ('\\', $NORTH) => [WEST]
        ('\\', $SOUTH) => [EAST]
        ('\\', $EAST) => [SOUTH]
        ('\\', $WEST) => [NORTH]
        _ => error("illegal move")
    end

    # remove directions that have been travelled before
    for dir in next_directions
        if tile.directions[Int(dir)]
            filter!(x-> x!=dir, next_directions)
        end
    end

    next_directions
end

function is_energized(tile::Tile)
    sum(tile.directions) > 0
end

function visualize_grid(g::Grid; energized = false)
    str = ""
    n_rows, n_cols = size(g)
    for row in 1:n_rows
        for col in 1:n_cols
            new_part = '_'
            if energized
                new_part = @match sum(g.tiles[row, col].directions) begin
                    0 => '.'
                    _ => '#'
                end
            elseif g.tiles[row, col].elem ∈ ['|', '-', '/', '\\']
                new_part = g.tiles[row, col].elem
            else
                new_part = @match g.tiles[row, col].directions begin
                    [true, false, false, false] => '^'
                    [false, true, false, false] => 'v'
                    [false, false, true, false] => '>'
                    [false, false, false, true] => '<'
                    [false, false, false, false] => '.'
                    arr => Char(sum(arr) + '0')
                end
            end
            str *= new_part
        end
        str *= '\n'
    end
    str
end

# recursive version
function move_into!(grid, r, c, dir::DIRECTION)
    tile = grid[r, c]
    new_directions = compute_next_direction(tile, dir)
    for new_dir in new_directions
        grid[r, c].directions[Int.(new_directions)] .= true
        new_r, new_c = rc_after_move(r, c, new_dir)
        move_into!(grid, new_r, new_c, new_dir)
    end
end

# Queue version (somewhat slower)
function move_into_queue!(grid, q)
    while !isempty(q)
        move = dequeue!(q)
        tile = grid[move.r, move.c]
        new_directions = compute_next_direction(tile, move.dir)
        for new_dir in new_directions
            grid[move.r, move.c].directions[Int.(new_directions)] .= true
            new_r, new_c = rc_after_move(move.r, move.c, new_dir)
            enqueue!(q, Move(new_r, new_c, new_dir))
        end
    end
end

struct Move
    r::Int
    c::Int
    dir::DIRECTION
end

function part1(inp, energized=false)
    grid = Grid(inp)
    move_into!(grid, 1, 1, EAST)

    # alternative with queue
    #q = Queue{Tuple{Int, Int, DIRECTION}}()
    #q = Queue{Move}()
    #enqueue!(q, Move(1, 1, EAST))
    #move_into_queue!(grid, q)

    sum(is_energized.(grid.tiles))
end

function edge_moves(mat)
    n_rows, n_cols = size(mat)
    edge_moves = Vector{Tuple{Int, Int, DIRECTION}}()

    # Top
    append!(edge_moves, [(1, c, SOUTH) for c in 1:n_cols])
    # Bottom
    append!(edge_moves, [(n_rows, c, NORTH) for c in 1:n_cols])
    # Left
    append!(edge_moves, [(r, 1, EAST) for r in 1:n_rows])
    # Right
    append!(edge_moves, [(r, n_cols, WEST) for r in 1:n_rows])
    edge_moves
end

function part2(inp)
    start_grid = Grid(inp)
    start_moves = edge_moves(start_grid.tiles)
    energized_tiles = zeros(Int, length(start_moves))
    Threads.@threads for (i, move) in [enumerate(start_moves)...]
        grid = Grid(inp)
        move_into!(grid, move...)
        energized_tiles[i] = sum(is_energized.(grid.tiles))
    end
    maximum(energized_tiles)
end

end # module
