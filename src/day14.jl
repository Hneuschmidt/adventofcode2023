module day14mod
FILENAME = "src/inputs/day14.txt"
export day14
import ..tools: file_to_string, emptyfilter, intparse_all
using Match


function day14()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

function part1(inp)
    inp |> strip |> char_mat |> move_pattern_north_until_same |> evaluate_pat
end

function part2(inp)
    inp |> strip |> char_mat |> rotate_one_billion_times |> evaluate_pat
end

function char_mat(pat_str)
    lines = split(pat_str, "\n")
    n_rows = length(lines)
    n_cols = length(lines[1])
    mat = Matrix{UInt8}(undef, (n_rows, n_cols))
    for c in 1:n_cols
        for r in 1:n_rows
            mat[r, c] = lines[r][c]
        end
    end
    
    mat
end

@enum DIRECTION NORTH SOUTH EAST WEST

function move_pattern(pat::Matrix{UInt8}, direction::DIRECTION)
    n_rows, n_cols = size(pat)
    # Because of the implementation of `move_pattern_north` it does not matter
    # if the east/west direction (after rotation) is flipped
    pat_view = @match direction begin
        $NORTH => pat
        $EAST => Transpose(view(pat, :, n_cols:-1:1))
        $SOUTH => view(pat, n_rows:-1:1, :)
        $WEST => Transpose(pat)
    end

    move_pattern_north_until_same(pat_view)
end

function move_pattern_north(pat)
    changed = false
    rows, cols = size(pat)
    for r in 1:rows-1
        north = view(pat, r, :)
        south = view(pat, r+1, :)
        for c in 1:cols
            if north[c] == UInt8('.') && south[c] == UInt8('O')
                north[c] = UInt8('O')
                south[c] = UInt8('.')
                changed = true
            end
        end
    end
    changed
end

function pretty_print(pat)
    println(join([String(pat[r, :]) for r in 1:size(pat)[1]], "\n"))
end

function move_pattern_north_until_same(pat)
    while move_pattern_north(pat)
    end
    pat
end

function one_rotation(pat)
    for dir in [NORTH, WEST, SOUTH, EAST]
        move_pattern(pat, dir)
    end
end

function rotate_one_billion_times(pat)
    start_rotations = rotate_pattern_until_same(pat) # before we consider the cycles
    cycle_length = rotate_pattern_until_same(pat)
    one_billion = Int(1e9)
    largest_multiple = ((one_billion - start_rotations - cycle_length) ÷ cycle_length) * cycle_length
    for _ in 1:(one_billion - start_rotations - largest_multiple - cycle_length)
        one_rotation(pat)
    end

    pat
end

# TODO this is a mutating function
function rotate_pattern_until_same(pat::Matrix{UInt8})
    visited = Dict{Matrix{UInt8}, Int}()
    visited[pat] = 1
    i = 1
    while true
        one_rotation(pat)
        hash = pat
        is_visited = get(visited, hash, -1)
        if is_visited != -1
            return i
        else
            visited[hash] = i
        end
        i += 1
    end
end

function evaluate_pat(pat::Matrix{UInt8})
    n_rows, _ = size(pat)
    acc = 0
    for r in 1:n_rows
        acc += sum(pat[r, :] .== UInt8('O')) * (n_rows - r + 1)
    end
    acc
end

end # module
