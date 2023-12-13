module day03mod
FILENAME = "src/inputs/day03.txt"
export day3
import ..tools: file_to_string

testinput = raw"467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
"

using Debugger

function day3()
    input = file_to_string(FILENAME)
    println("Part 1: ", part1(input))
    println("Part 2: ", part2(input))
end

function has_poison(range, schematic)
    l, r = first(range), last(range)
    safe_range = max(l, 1):min(r, length(schematic))
    if isempty(safe_range)
        #println("empty range")
        return false
    end

    !isnothing(match(r"[^\w\.\n]", schematic[safe_range]))
end

function is_poisoned(range, schematic)
    line_length = first(findfirst("\n", schematic))
    l, r = first(range), last(range)
    @bp
    bottom_left = l + line_length - 1
    bottom_right = bottom_left + length(range) + 1
    top_left = l - line_length - 1
    top_right = top_left + length(range) + 1
    any(has_poison.([top_left:top_right, bottom_left:bottom_right, l-1:r+1], schematic))
end

function find_numbers(thestring)
    eachmatch(r"(\d+)", thestring)
end

function get_whole_number(idx, haystack)

    left = idx
    right = idx
    while left > 1 && isdigit(haystack[left-1])
        left -= 1
    end

    while right < length(haystack) && isdigit(haystack[right+1])
        right += 1
    end
    parse(Int, haystack[left:right])
end

function gear_ratio(idx, schematic)::Int
    line_length = first(findfirst("\n", schematic))
    top_left = (idx - line_length - 1)
    top_right = top_left + 2
    bottom_left = idx + line_length - 1
    bottom_right = bottom_left + 2

    raw_number_matches = find_numbers.([schematic[top_left:top_right], schematic[bottom_left:bottom_right], schematic[idx-1:idx-1], schematic[idx+1:idx+1]])

    offsets = [top_left, bottom_left, idx-1, idx+1]
    numbers = Int[]
    for (i, ms) in enumerate(raw_number_matches)
        for m in ms
            push!(numbers, get_whole_number(m.offset + offsets[i]-1, schematic))
        end
    end

    if sum(length(numbers)) != 2
        return 0 # not a gear
    end

    @assert length(numbers) == 2
    gr = numbers[1] * numbers[2]
    println("gear ratio of numbers ", numbers, " is ", gr)
    gr
end



function part1(schematic)
    test_range(rg) = is_poisoned(rg, schematic)
    poison_filter(ranges) = filter(test_range, ranges)
    intparser(num) = parse(Int, num)

    filtered = findall(r"(\d+)", schematic) |> poison_filter 
    getindex.(schematic, filtered) .|> intparser |> sum
end
    

function part2(schematic)
    gear_ratio_schematic(gear) = gear_ratio(first(gear), schematic)

    findall(r"\*", schematic) .|> gear_ratio_schematic |> sum
end 

end # module
