module day10mod
FILENAME = "src/inputs/day10.txt"
export day10
import ..tools: file_to_string, emptyfilter, intparse_all
using Debugger

exampleinp1= "-L|F7
7S-7|
L|7||
-L-J|
L|-JF"

exampleinp2= "7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ"

struct Map
    data::String
    n_rows::Int
    n_cols::Int
    start::Tuple{Int, Int}
end

function Map(data)
    n_cols = first(findfirst("\n", data)) - 1
    data = replace(data, "\n"=>"")
    n_rows = length(data) ÷ n_cols
    start = first(findfirst("S", data))
    start_idx = divrem(start, n_cols) .+ (1, 0)
    Map(data, n_rows, n_cols, start_idx)
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

function day10()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

@enum DIRECTION UP DOWN LEFT RIGHT START

function find_step(map, pos, dir::DIRECTION)
    val = map[pos]
    @bp

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
        @bp
        return adir
    end
end

function take_step(m::Map, pos, dir::DIRECTION)
    new_dir = find_step(m, pos, dir)
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

function walk_loop(map::Map)
    pos, dir = take_step(map, map.start, START)
    steps = 1
    while pos != map.start && dir != START
        pos, dir = take_step(map, pos, dir)
        steps += 1
    end

    steps
end

function part1(inp)
    m = Map(inp)
    walk_loop(m) ÷ 2
end

function part2(inp)
    
end

end # module
#
#tried: 13656 (too hight)
