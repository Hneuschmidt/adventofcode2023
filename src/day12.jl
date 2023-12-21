module day12mod
FILENAME = "src/inputs/day12.txt"
export day12
import ..tools: file_to_string, emptyfilter, intparse_all
using Debugger

testinp = "???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1"

function day12()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

struct Constellation
    question_marks::UInt128
    hashes::UInt128
    dots::UInt128
    string_length::UInt128
end

function Constellation(str)
    dots, hashes, question_marks = zero(UInt128), zero(UInt128), zero(UInt128)
    for (i, c) in enumerate(str)
        if c == '.'
            dots |= (one(UInt128) << (i-1))
        elseif c == '#'
            hashes |= (one(UInt128) << (i-1))
        elseif c == '?'
            question_marks |= (one(UInt128) << (i-1))
        end
    end
    Constellation(question_marks, hashes, dots, length(str))
end

function Base.string(c::Constellation)
    string(c.dots | c.hashes) * string(c.question_marks)
end

#! Turns the bit representation of Constellation
# back into a string like in the task
function pretty_print(c::Constellation)
    if (c.hashes & c.dots) & c.question_marks != 0
        error("illegal constellation")
    end
    str = fill('u', c.string_length)
    for i in 1:c.string_length
        mask = one(UInt128) << (i-1)
        if count_ones(c.hashes & mask) == 1
            str[i] = '#'
        elseif count_ones(c.dots & mask) == 1
            str[i] = '.'
        elseif count_ones(c.question_marks & mask) == 1
            str[i] = '?'
        else
            str[i] = 'x'
        end
    end
    String(str)
end

#! Shift all componenst of `old` by `shift`
function advance(old::Constellation, shift::T) where T <: Integer
    question_marks = old.question_marks >> shift
    hashes = old.hashes >> shift
    dots = old.dots >> shift
    string_length = old.string_length - shift
    Constellation(question_marks, hashes, dots, string_length)
end

function free_places(c::Constellation)
    c.hashes | c.question_marks
end

function separator_places(c::Constellation)
    c.dots | c.question_marks
end

function gen_cache_key(groups, constellation::Constellation)
    #string(groups) * string(constellation) # string version is quite a lot slower
    (constellation, groups)
end

function set_dot(c::Constellation, pos)
    question_marks = c.question_marks ⊻ one(UInt128)
    dots = c.dots | one(UInt128)
    Constellation(question_marks, c.hashes, dots, c.string_length)
end

#! Recursively calculate the possible number of arrangements
#! to fit groups of lengths `groups` in `constellation`.
#! `cache` gets passed on to all recusive calls
function number_of_matches(groups, constellation, cache)
    cache_key = gen_cache_key(groups, constellation)
    cache_entry = get(cache, cache_key, -1)
    if cache_entry != -1
        return cache_entry
    end
    if isempty(groups)
        # The constellation may not have any more
        # hashes that have not been used up by the placed groups
        return Int(constellation.hashes == 0)
    end

    group = first(groups)
    mask = UInt128(2^group -1) # e.g. 3 --> 0b00000111
    next_placement = -1
    for offset in 1:Int(constellation.string_length) - group
        # finds a group composed of '?' or '#', at least the length of the group
        # offset starts at one. This is fine, because the first character is always
        # used for separation.
        if count_ones(free_places(constellation) & mask << offset) == group 
            sep_mask = one(UInt128) << (group + 1) | one(UInt128)
            # checks if a '.' or '?' is placed before and after the group
            if count_ones(separator_places(constellation) & sep_mask << (offset-1)) == 2
                next_placement = offset
                break
            end
        end
    end

    if next_placement == -1
        cache[cache_key] = 0
        return 0
    end

    # Check if the group was placed after a '#', which is not allowed to happen
    skip_mask = UInt128(2^(next_placement + group)-1) ⊻ (mask << next_placement)
    if constellation.hashes & skip_mask != 0 # skipped #s
        cache[cache_key] = 0
        return 0
    end

    new_constellation_placed = set_dot(advance(constellation, next_placement + group), 1)
    n_matches = number_of_matches(groups[2:end], new_constellation_placed, cache)
    

    # Checks if the first character of the newly placed group is a question mark,
    # in which case it may be skipped so this branch also needs to be checked.
    # If the first character is a '#' we don't have a choice.
    if ((constellation.question_marks >> next_placement)  & one(UInt128)) != 0
        new_constellation_not_placed = advance(constellation, next_placement)
        n_matches += number_of_matches(groups, new_constellation_not_placed, cache)
    end

    cache[cache_key] = n_matches
    cache[cache_key]
end

function placements_in_line(line)
    # TODO can compact line string (... -> .)
    line_str, group_str = split(line, " ")
    groups = intparse_all(group_str)
    constellation = Constellation("." * line_str * ".")
    number_of_matches(groups, constellation, Dict{Tuple{Constellation, Vector{Int}}, Int}())
end

function part1(inp)
    split(inp, "\n") |> emptyfilter .|> placements_in_line |> sum
end

function unfold(str)
    line_str, group_str = split(str, " ")
    ((line_str * "?")^5)[1:end-1] * " " * (group_str*",")^5
end

function part2(inp)
    strlines = split(inp, "\n") |> emptyfilter .|> unfold
    acc = 0
    for (i, line) in enumerate(strlines)
        #println("$i/$(length(strlines))")
        res = placements_in_line(line)
        acc += res
    end
    acc

end
end # module
