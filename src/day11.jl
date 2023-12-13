
module day11mod
FILENAME = "src/inputs/day11.txt"
export day11
import ..tools: file_to_string, emptyfilter, intparse_all
using Debugger

testinp = "...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#....."

struct Map
    data::String
    n_rows::Int
    n_cols::Int
    galaxies::Vector{Tuple{Int, Int}}
    empty_rows::Vector{Int}
    empty_cols::Vector{Int}
end


# TODO move to tools
function rc(map::Map, idx)
    (r, c) = divrem(idx, map.n_cols)
    (r+1, c)
end

function idx(map, r, c)
    (r - 1) * map.n_cols + c
end


function Map(data)
    n_cols = first(findfirst("\n", data)) - 1
    data = replace(data, "\n"=>"")
    n_rows = length(data) ÷ n_cols
    Map(data, n_rows, n_cols, Vector{Tuple{Int, Int}}(), Vector{Int}(), Vector{Int}())
end

function add_galaxies!(m::Map)
    for (i, c) in enumerate(m.data)
        if c == '#'
            @bp
            push!(m.galaxies, rc(m, i))
        end
    end
end

function add_empty_rows_and_cols!(m::Map)
    n_rows, n_cols = m.n_rows, m.n_cols
    for row_idx in 1:n_rows
        row = m.data[idx(m, row_idx, 1):idx(m, row_idx, n_cols)]
        if isnothing(findfirst("#", row))
            push!(m.empty_rows, row_idx)
        end
    end

    for col_idx in 1:n_cols
        col = m.data[idx(m, 1, col_idx):n_cols:idx(m, n_rows, col_idx)]
        if isnothing(findfirst("#", col))
            push!(m.empty_cols, col_idx)
        end
    end
end

function crosses(indices, s, e)
    thes = min(s, e)
    thee = max(s, e)
    acc = 0
    for i in thes:thee
        if i in indices
            acc += 1
        end
    end
    acc
end

function shortest_paths(m)
    distances = Vector{Int}()
    for i in eachindex(m.galaxies)
        for j in (i+1):length(m.galaxies)
            (r1, c1) = m.galaxies[i]
            (r2, c2) = m.galaxies[j]
            dist =  abs(r2 - r1) + abs(c2 - c1)
            dist += crosses(m.empty_rows, r1, r2)
            dist += crosses(m.empty_cols, c1, c2)
            @bp
            push!(distances, dist)
        end
    end
    distances
end

function day11()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

function part1(inp)
    m = Map(inp)
    println("rows: ", m.n_rows, ", cols: ", m.n_cols)
    add_galaxies!(m)
    add_empty_rows_and_cols!(m)
    distances = shortest_paths(m)
#     println("Galaxies: ", m.galaxies)
#     println("empty_rows: ", m.empty_rows)
#     println("empty_cols: ", m.empty_cols)
#     println("Distances: ", distances)
#     println("length(Distances): ", length(distances))
    # TODO why this hack?
    sum(distances)
end

function part2(inp)
    
end

end #module
