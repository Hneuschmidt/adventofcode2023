module day04mod
FILENAME = "src/inputs/day04.txt"
export day4
import ..tools: file_to_string

function day4()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
    
end

function overlap(card)
    cardnumber, value = split(card, ':')
    winning, owned = split(value, "|")
    winning_numbers = Set(parse_all(winning))
    owned_numbers = parse_all(owned)
    [n for n in owned_numbers if n in winning_numbers]
end

function card_value(card)
    theoverlap = overlap(card)
    if isempty(theoverlap)
        return 0
    end

    2 ^ (length(theoverlap)-1)
end

function is_whitespace(text)
    for char in text
        if !isspace(char)
            return false
        end
    end
    true
end

emptyfilter(cards) = filter(!isempty, cards)
whitespacefilter(cards) = filter(!is_whitespace, cards)

function part1(cards)
    [eachline(IOBuffer(cards))...] |> emptyfilter .|> card_value |> sum
end

function parse_all(number_strings)
    intparse(x) = parse(Int, x)
    to_parse = split(number_strings, " ") |> emptyfilter  .|> strip
    to_parse .|> intparse |> collect
end

function count_copies(cards)
end

function part2(cards)
    cards_list = split(cards, "\n") |> emptyfilter
    multipliers = ones(Int, length(cards_list))
    for (n, card) in enumerate(cards_list)
        n_overlap = length(overlap(card))
        for m in 1:n_overlap
            multipliers[n+m] += multipliers[n]
        end
    end
    
    sum(multipliers)
end


end # module
