module day10mod
FILENAME = "src/inputs/day10.txt"
export day10
import ..tools: file_to_string, emptyfilter, intparse_all
using Match
using Debugger

# Map data structure ---------------------------------------------------------- 

struct Map
    data::Vector{Char}
    n_rows::Int
    n_cols::Int
    start::Tuple{Int, Int}
end

function Map(data)
    n_cols = first(findfirst("\n", data)) - 1
    data = Vector{Char}(replace(data, "\n"=>""))
    n_rows = length(data) ÷ n_cols
    start = first(findfirst('S', String(data)))
    start_idx = divrem(start, n_cols) .+ (1, 0)
    Map(data, n_rows, n_cols, start_idx)
end

function rows(m::Map)
    [m.data[row*m.n_cols+1:(row+1)*m.n_cols] for row in 0:(m.n_rows-1)]
end

function Base.getindex(m::Map, r::Int, c::Int)
    map.data[idx(m, r, c)]
end

function Base.getindex(m::Map, t::Tuple{Int, Int})
    r, c = t
    m.data[idx(m, r, c)]
end

function rc(map::Map, idx)
    (r, c) = divrem(idx, map.n_cols)
    (r+1, c)
end

function idx(map, r, c)
    (r - 1) * map.n_cols + c
end

# Main part ------------------------------------------------------------------- 

function day10()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

@enum DIRECTION UP DOWN LEFT RIGHT START

function find_step(map, pos, dir::DIRECTION; replace_symbols=false)
    val = map[pos]
    if replace_symbols && val != 'S'
        map.data[idx(map, pos...)] = main_loop_map[val]
    end

    if val == '|'
        return dir
    elseif val == '-'
        return dir
    elseif val == 'L'
        if dir == DOWN
            return RIGHT
        elseif dir == LEFT
            return UP
        else
            error("illegal step")
        end
    elseif val == 'J'
        if dir == DOWN
            return LEFT
        elseif dir == RIGHT
            return UP
        else
            error("illegal step")
        end
    elseif val == '7'
        if dir == RIGHT
            return DOWN
        elseif dir == UP
            return LEFT
        else
            error("illegal step")
        end
    elseif val == 'F'
        if dir == UP
            return RIGHT
        elseif dir == LEFT
            return DOWN
        else
            error("illegal step")
        end
    elseif val == '.'
        error("how did I get here?")
    elseif val == 'S'
        r, c, adir = find_legal_move(map, pos)[1]
        return adir
    end
end

function take_step(m::Map, pos, dir::DIRECTION; replace_symbols=false)
    new_dir = find_step(m, pos, dir, replace_symbols=replace_symbols)
    if new_dir == UP
        return pos .- (1, 0), new_dir
    elseif new_dir == DOWN
        return pos .+ (1, 0), new_dir
    elseif new_dir == LEFT
        return pos .- (0, 1), new_dir
    elseif new_dir == RIGHT
        return pos .+ (0, 1), new_dir
    else
        error("taking step with starting direction")
    end
end

function find_legal_move(map, pos)
    moves = Tuple{Int, Int, DIRECTION}[]
    newpos = pos .- (1, 0)
    if map[newpos] in ['|', '7', 'F']
        push!(moves, (newpos..., UP))
    end
    newpos = pos .+ (1, 0)
    if map[newpos] in ['|', 'L', 'J']
        push!(moves, (newpos..., DOWN))
    end
    newpos = pos .- (0, 1)
    if map[newpos] in ['-', 'L', 'F']
        push!(moves, (newpos..., LEFT))
    end
    newpos = pos .+ (0, 1)
    if map[newpos] in ['-', 'J', '7']
        push!(moves, (newpos..., RIGHT))
    end
    moves
end

function walk_loop(map::Map; replace_symbols=false)
    pos, dir = take_step(map, map.start, START)
    steps = 1
    while pos != map.start && dir != START
        pos, dir = take_step(map, pos, dir, replace_symbols=replace_symbols)
        steps += 1
    end

    steps
end

function part1(inp)
    m = Map(inp)
    walk_loop(m) ÷ 2
end

@enum STATE INSIDE OUTSIDE

function opposite(state::STATE)
    if state == INSIDE
        OUTSIDE
    else
        INSIDE
    end

end

const main_loop_map = Dict(
    '|'=> '0',
    '-'=> '1',
    'L'=> '2',
    'J'=> '3',
    '7'=> '4',
    'F'=> '5',
)

function uncover_start_symbol(m::Map)
    start_move1, start_move2 = find_legal_move(m, m.start)
    @match (start_move1[3], start_move2[3]) begin
        (($UP, $RIGHT) || ($RIGHT, $UP)) => 'L'
        (($UP, $LEFT) || ($LEFT, $UP)) => 'J'
        (($DOWN, $LEFT) || ($LEFT, $DOWN)) => '7'
        (($DOWN, $RIGHT) || ($LEFT, $RIGHT)) => 'F'
        (($LEFT, $RIGHT) || ($RIGHT, $LEFT)) => '-'
        (($UP, $DOWN) || ($DOWN, $UP)) => '|'
    end
end

function part2(inp)
    m = Map(inp)
    start_symbol = uncover_start_symbol(m)
    walk_loop(m, replace_symbols=true)
    m.data[idx(m, m.start...)] = main_loop_map[start_symbol]

    acc = 0
    for row in rows(m)
        state = OUTSIDE
        # Outside or inside we can only hit corners L or F.
        # On the loop we can only hit corners J or 7.
        # If the corner that makes us enter the border points in the same direction
        # as the corner that makes us leave the border, we do not need to change the status.
        # '|' always makes us change the status.
        last_corner_direction = RIGHT # no corner
        switch = false
        for c in row
            switch = @match c begin
                $(main_loop_map['|']) => true
                $(main_loop_map['L']) => begin
                    last_corner_direction = UP
                    false
                end
                $(main_loop_map['F']) => begin
                    last_corner_direction = DOWN
                    false
                end
                $(main_loop_map['J']) => last_corner_direction != UP
                $(main_loop_map['7']) => last_corner_direction != DOWN
                _ => false
            end
            if switch
                state = opposite(state)
            end
            # count inside tiles if we are not on the border and inside the loop
            if c ∉ values(main_loop_map) && state == INSIDE
                acc += 1
            end
        end
    end
    acc
end

end # module
