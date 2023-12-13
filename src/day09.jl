module day09mod
FILENAME = "src/inputs/day09.txt"
export day9
import ..tools: file_to_string, emptyfilter, intparse_all

testreadings = "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"

function day9()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

difference(sequence::Vector{Int}) = [sequence[i] - sequence[i-1] for i in 2:length(sequence)]

function extend_sequence(sequence)
    if all(sequence .== 0) return [sequence..., 0] end
    [sequence..., sequence[end] + extend_sequence(difference(sequence))[end]]
end

function extend_sequence_backwards(sequence)
    if all(sequence .== 0) return [0, sequence...] end
    [sequence[1] - extend_sequence_backwards(difference(sequence))[1], sequence...]
end

function part1(inp)
    split(inp, "\n") |> emptyfilter .|> intparse_all .|> extend_sequence .|> last |> sum
end

function part2(inp)
    #split(inp, "\n") |> emptyfilter .|> intparse_all .|> extend_sequence_backwards .|> first |> sum
    split(inp, "\n") |> emptyfilter .|> intparse_all .|> reverse .|> extend_sequence .|> last |> sum
end

# tried answers
# 2185006187: too high
end # module
