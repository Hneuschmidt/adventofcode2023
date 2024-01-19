module day18mod
FILENAME = "src/inputs/day18.txt"
export day18
import ..tools: file_to_string, emptyfilter, intparse_all
using Match

function day18()
    inp = file_to_string(FILENAME)
    println(part1(inp))
    println(part2(inp))
end

"""
Determine the area of a non-intersecting polygon.
"""
function shoelace(xs, ys)
    @assert length(xs) == length(ys)
    if !(xs[begin] == xs[end] && ys[begin] == ys[end])
        xs = [xs..., xs[1]]
        ys = [ys..., ys[1]]
    end
    ℓ = length(xs)-1
    0.5(sum([xs[i]*ys[i+1] - xs[i+1]*ys[i] for i in 1:ℓ]))
end

function shoelace((xs, ys))
    shoelace(xs, ys)
end

function parse_line(line)
    dir, n_steps, color_parens = split(line, " ")
    (dir=dir[1], n_steps=parse(Int, n_steps), color=color_parens[2:end-1])
end

function corner_coordinates(moves)
    current = CartesianIndex(1, 1)
    xs = [current[1]]
    ys = [current[2]]
    for (;dir, n_steps) in moves
        current += @match dir begin
            'L' => CartesianIndex(-n_steps, 0)
            'R' => CartesianIndex(n_steps, 0)
            'U' => CartesianIndex(0, -n_steps)
            'D' => CartesianIndex(0, n_steps)
        end
        push!(xs, current[1])
        push!(ys, current[2])
    end

    xs, ys
end

function boundary_length(moves)
    sum([m.n_steps for m in moves])
end

function part1(inp)
    moves = split(inp, "\n") |> emptyfilter .|> parse_line
    area = moves |> corner_coordinates  |> shoelace |> Int
    area + (boundary_length(moves) ÷ 2) + 1
end

function part2(inp)
    moves = split(inp, "\n") |> emptyfilter .|> parse_line .|> last .|> hex_to_instr
    area = moves |> corner_coordinates  |> shoelace |> Int
    area + (boundary_length(moves) ÷ 2) + 1
end

function hex_to_instr(hex_str)
    dir = @match hex_str[end] begin
        '0' => 'R'
        '1' => 'D'
        '2' => 'L'
        '3' => 'U'
    end

    n_steps = parse(Int, hex_str[2:end-1], base=16)
    (dir=dir, n_steps=n_steps)
end

end # module
