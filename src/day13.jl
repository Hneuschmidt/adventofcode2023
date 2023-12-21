module day13mod
FILENAME = "src/inputs/day13.txt"
export day13
import ..tools: file_to_string, emptyfilter, intparse_all
using Debugger

function day13()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

struct MirrorPattern
    n_rows::Int
    n_columns::Int
    mmap::BitArray
end

function MirrorPattern(str::T) where T <: AbstractString
    lines = split(str, "\n")
    n_rows = length(lines)
    n_columns = length(first(lines))
    mmap = falses((n_rows, n_columns))
    for c in 1:n_columns
        for r in 1:n_rows
            @inbounds mmap[r, c] |= lines[r][c] == '#'
        end
    end
    MirrorPattern(n_rows, n_columns, mmap)
end

function is_horizontal_mirror(m::MirrorPattern, row)
    up, down = row, row+1
    dist = min((up - 1), (m.n_rows - down))
    !any(m.mmap[up-dist:up, :] .⊻ m.mmap[down+dist:-1:down, :])
end

function is_horizontal_mirror_smudge(m::MirrorPattern, row)
    up, down = row, row+1
    dist = min((up - 1), (m.n_rows - down))
    sum(m.mmap[up-dist:up, :] .⊻ m.mmap[down+dist:-1:down, :]) == 1
end

function is_vertical_mirror(m::MirrorPattern, col)
    left, right = col, col+1
    dist = min((left - 1), (m.n_columns - right))
    !any(m.mmap[:, left-dist:left] .⊻ m.mmap[:, right+dist:-1:right])
end

function is_vertical_mirror_smudge(m::MirrorPattern, col)
    left, right = col, col+1
    dist = min((left - 1), (m.n_columns - right))

    sum(m.mmap[:, left-dist:left] .⊻ m.mmap[:, right+dist:-1:right]) == 1
end

function find_mirrors(m::MirrorPattern)
    row_mirrors = Int[]
    col_mirrors = Int[]
    for r in 1:m.n_rows-1
        if m.mmap[r, :] == m.mmap[r+1, :] && is_horizontal_mirror(m, r)
            push!(row_mirrors, r)
        end
    end

    for c in 1:m.n_columns-1
        if m.mmap[:, c] == m.mmap[:, c+1] && is_vertical_mirror(m, c)
            push!(col_mirrors, c)
        end
    end
    
    row_mirrors, col_mirrors
end

function find_mirrors_smudge(m::MirrorPattern)
    row_mirrors = Int[]
    col_mirrors = Int[]
    for r in 1:m.n_rows-1
        if is_horizontal_mirror_smudge(m, r)
            push!(row_mirrors, r)
        end
    end
    
    for c in 1:m.n_columns-1
        if is_vertical_mirror_smudge(m, c)
            push!(col_mirrors, c)
        end
    end
    
    row_mirrors, col_mirrors
end

function pattern_number(m)
    row_mirrors, col_mirrors = find_mirrors(m)
    sum(col_mirrors) + sum(row_mirrors) * 100
end

function pattern_number_smudge(m)
    row_mirrors, col_mirrors = find_mirrors_smudge(m)
    sum(col_mirrors) + sum(row_mirrors) * 100
end

function part1(inp)
    split(inp, "\n\n") |> emptyfilter .|> MirrorPattern .|> pattern_number |> sum
end

function part2(inp)
    split(inp, "\n\n") |> emptyfilter .|> MirrorPattern .|> pattern_number_smudge |> sum
end

end # module
