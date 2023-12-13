module day01mod
    
FILENAME = "src/inputs/day01.txt"
export day1
import ..tools: file_to_string

# Topic: Unit testing

function day1()
    input = file_to_string(FILENAME)
    println("Part 1: ", part1(input))
    println("Part 2: ", part2(input))
end

# much easier: find first occurence of either word or digit, then stop
# do the same from the back
# be happy
function ffsfirst(something_or_nothing)
    if isnothing(something_or_nothing)
        nothing
    else
        first(something_or_nothing)
    end
end

function words_to_digits(text)
    newtext = ""
    for line in split(text, "\n")
        indices_first = 1000 .* ones(Int, 9)
        indices_last = .-ones(Int, 9)
        if isempty(line) continue end

        for n in 1:9
            # words
            key = reverse_wordmap[n] # "one", "two", etc
            number_string = "$n"
            first_idx = ffsfirst(findfirst(key, line))
            last_idx = ffsfirst(findlast(key, line))
            if !isnothing(first_idx)
                indices_first[n] = first_idx
            end
            if !isnothing(last_idx)
                indices_last[n] = last_idx
            end

            # numbers
            first_idx_number = ffsfirst(findfirst(number_string, line))
            last_idx_number = ffsfirst(findlast(number_string, line))

            if !isnothing(first_idx_number) && first_idx_number < indices_first[n]
                indices_first[n] = first_idx_number
            end
            if !isnothing(last_idx_number) && last_idx_number > indices_last[n]
                indices_last[n] = last_idx_number
            end
        end

        first_number = argmin(indices_first)
        last_number = argmax(indices_last)
        newtext = newtext * "$first_number$last_number\n"

    end
    newtext
end

function part1(calibration)
    # No currying, bah :(
    extract_number(line) = filter(isdigit, line) .|> [first, last] |> (digits -> "$(first(digits))$(last(digits))") |> (x->(parse(Int, x)))

    split(calibration, "\n") |> (line->filter(!isempty, line)) .|> (line->extract_number(line)) |> sum
end


function part2(calibration)
    part1(words_to_digits(calibration))
end

const wordmap = Dict(
   #("zero"=>'0'),
   ("one"=>'1'),
   ("two"=>'2'),
   ("three"=>'3'),
   ("four"=>'4'),
   ("five"=>'5'),
   ("six"=>'6'),
   ("seven"=>'7'),
   ("eight"=>'8'),
   ("nine"=>'9'),
)

const reverse_wordmap = Dict(
   #("zero"=>'0'),
   (1=>"one"),
   (2=>"two"),
   (3=>"three"),
   (4=>"four"),
   (5=>"five"),
   (6=>"six"),
   (7=>"seven"),
   (8=>"eight"),
   (9=>"nine"),
)
end

