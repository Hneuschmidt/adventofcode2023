module day07mod
FILENAME = "src/inputs/day07.txt"
export day7
import ..tools: file_to_string, intparse, emptyfilter# , whitespacefilter

@enum HANDTYPE HIGH_CARD=0 ONE_PAIR=1 TWO_PAIR=2 THREE_OF_A_KIND=3 FULL_HOUSE=4 FOUR_OF_A_KIND=5 FIVE_OF_A_KIND=6 UNKNOWN=7

struct Hand
    cards::Vector{Char}
    bid::Int
    type::HANDTYPE
end

function Hand(hand_str)
    hand, bid = split(hand_str)
    cards = Vector{Char}
    temphand = Hand([c for c in hand], parse(Int, bid), UNKNOWN)
    hand = Hand(temphand.cards, temphand.bid, handtype(temphand))
end

function Hand2(hand_str)
    hand, bid = split(hand_str)
    cards = Vector{Char}
    temphand = Hand([c for c in hand], parse(Int, bid), UNKNOWN)
    hand = Hand(temphand.cards, temphand.bid, handtype2(temphand))
end

Base.:+(type::HANDTYPE, x::Int) = (Int(type) + x) |> HANDTYPE


function handtype2(hand::Hand)
    handmap = Dict{Char, Int}()
    for c in hand.cards
        old = get(handmap, c, 0)
        handmap[c] = old + 1
        continue
    end
    n_jokers = get(handmap, 'J', 0)
    vals = values(handmap)
    type = handtype(hand)
    if n_jokers == 1
        # FULL_HOUSE, FIVE_OF_A_KIND not possible
        if type == HIGH_CARD
            type = ONE_PAIR
        elseif type == ONE_PAIR
            type = THREE_OF_A_KIND
        elseif type == TWO_PAIR
            type = FULL_HOUSE
        elseif type == THREE_OF_A_KIND
            type = FOUR_OF_A_KIND
        elseif type == FOUR_OF_A_KIND
            type = FIVE_OF_A_KIND
        else
            error("not possible: card $(string(hand.cards)) has type $type")
        end
    elseif n_jokers == 2
        # HIGH_CARD, FOUR_OF_A_KIND, FIVE_OF_A_KIND not possible
        if type == ONE_PAIR # these are the jokers
            type = THREE_OF_A_KIND
        elseif type == TWO_PAIR
            type = FOUR_OF_A_KIND
        elseif type == THREE_OF_A_KIND || type == FULL_HOUSE
            type = FIVE_OF_A_KIND
        else
            error("not possible: card $(string(hand.cards)) has type $type")
        end
    elseif n_jokers == 3
        # HIGH_CARD, ONE_PAIR, TWO_PAIRS, FOUR_OF_A_KIND, FIVE_OF_A_KIND not possible
        if type == THREE_OF_A_KIND
            type = FOUR_OF_A_KIND
        elseif type == FULL_HOUSE
            type = FIVE_OF_A_KIND
        else
            error("not possible: card $(string(hand.cards)) has type $type")
        end
    elseif n_jokers > 3
        type = FIVE_OF_A_KIND
    end

    type
end


function handtype(hand::Hand)
    handmap = Dict{Char, Int}()
    for c in hand.cards
        old = get(handmap, c, 0)
        handmap[c] = old + 1
        continue
    end
    vals = values(handmap)
    max_rep = maximum(vals)
    if max_rep == 5
        return FIVE_OF_A_KIND
    elseif max_rep == 4
        return FOUR_OF_A_KIND
    elseif max_rep == 3
        if 2 in vals
            return FULL_HOUSE
        else
            return THREE_OF_A_KIND
        end
    elseif max_rep == 2
        if maximum(sort([vals...])[1:end-1]) == 2
            return TWO_PAIR
        else
            return ONE_PAIR
        end
    else
        return HIGH_CARD
    end
end

function handless(left::Hand, right::Hand)
    if left.type < right.type
        return true
    elseif right.type < left.type
        return false
    end
    values = Dict(
        "A"=>14,
        "K"=>13,
        "Q"=>12,
        #"J"=>11,
        "T"=>10,
        "J"=>1,
    )
    for n in 1:9 
        values["$n"] = n
    end

    for (c1, c2) in zip(left.cards, right.cards)
        c1 = string(c1)
        c2 = string(c2)
        if values[c1] < values[c2]
            return true
        elseif values[c2] < values[c1]
            return false
        end
    end

    return false
end

hands = "32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
"

function day7()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

function part1(hands)
    handsplit = split(hands, "\n") |> emptyfilter
    hands = Hand.(handsplit)
    sorted = sort(hands, lt=handless)
    #println(sorted)
    #println(sorted[end-10:end])
    acc = 0
    for (i, hand) in enumerate(sorted)
        acc += i*hand.bid
    end
    acc
end
function part2(hands)
    handsplit = split(hands, "\n") |> emptyfilter
    hands = Hand2.(handsplit)
    sorted = sort(hands, lt=handless)
    #println(sorted)
    #println(sorted[end-10:end])
    acc = 0
    for (i, hand) in enumerate(sorted)
        acc += i*hand.bid
    end
    acc
end

end # module
