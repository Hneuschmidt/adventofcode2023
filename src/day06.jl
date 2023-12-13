module day06mod
FILENAME = "src/inputs/day06.txt"
export day6
import ..tools: file_to_string, intparse, emptyfilter, whitespacefilter
using Debugger

# test data
example_races = "Time: 7 15 30
Distance: 9 40 200
"
times = [7, 15, 30]
distances = [9, 40, 200]
results = [4, 8, 9]

function day6()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

#     if arg < 0
#         return Float64[]
#     elseif arg == 0
#         return 0.5neg_p
#     end
function solve_quadratic_neg_p(neg_p::Int, q::Int)::Array{Float64}
    arg = 0.25*(neg_p^2) - q
    theroot = sqrt(arg)
    Float64[0.5neg_p - theroot, 0.5neg_p + theroot]
end

    # distance = time_pressed * (time - time_pressed)
function calc_available_records(time, distance)
    sol = solve_quadratic_neg_p(time, distance)
    ints = [1 for n in sol if floor(n) == n]
    floor(Int, sol[2]) - floor(Int, sol[1]) - ceil(Int, sum(ints) / 2)
end

function part1(inp)
    time_str, distance_str = split(inp, "\n")
    times = parse.(Int, [m.match for m in eachmatch(r"\d+", time_str)])
    distances = parse.(Int, [m.match for m in eachmatch(r"\d+", distance_str)])
    reduce(*, calc_available_records.(times, distances))
end

function part2(inp)
    time_str, distance_str = split(inp, "\n")
    time = parse(Int, split(strip(time_str), ":")[2] |> whitespacefilter)
    distance = parse(Int, split(strip(distance_str), ":")[2] |> whitespacefilter)

    calc_available_records(time, distance)
end
end # module
