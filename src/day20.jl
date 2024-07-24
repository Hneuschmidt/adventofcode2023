module day20mod
FILENAME = "src/inputs/day20.txt"
export day20
import ..tools: file_to_string, emptyfilter, intparse_all, whitespacefilter

using Match
using Test

@enum NODE_TYPE BROADCAST FLIPFLOP CONJUNCTION SINK
@enum STATE LOW HIGH

function invert(state::STATE)
    @match state begin
        $LOW => HIGH
        $HIGH => LOW
    end
end

struct Message
    origin::Symbol
    target::Symbol
    content::STATE
end

struct Network
    network::Dict{Symbol, Vector{Symbol}}
    state::Dict{Symbol, Dict{Symbol, STATE}}
    types::Dict{Symbol, NODE_TYPE}
end


function day20()
    inp = file_to_string(FILENAME)
    println(part1(inp))
    println(part2(inp))
end

function part1(inp)
    network = Network(split(inp, "\n"))
    low_pulses = 0
    high_pulses = 0
    for i in 1:1000
        message_queue = [Message(:init, :broadcaster, LOW)]
        while !isempty(message_queue)
            message = popfirst!(message_queue)
            #println("Sending message: $(message.origin) --$(message.content)-> $(message.target)")
            if message.content == LOW
                low_pulses += 1
            else
                high_pulses += 1
            end
            new_messages = apply!(network, message)
            append!(message_queue, new_messages)
        end
    end

    println("low pulses: ", low_pulses)
    println("high pulses: ", high_pulses)

    return low_pulses * high_pulses
end

function part2(inp)
    network = Network(split(inp, "\n"))
    rx_parent = :unknown
    for (node, children) in network.network
        if :rx in children
            rx_parent = node
        end
    end

    cycles_per_child = Dict(k=>0 for k in keys(network.state[rx_parent]))

    i = 0
    while true
        i+=1
        message_queue = [Message(:init, :broadcaster, LOW)]
        while !isempty(message_queue)
            message = popfirst!(message_queue)
            #println("Sending message: $(message.origin) --$(message.content)-> $(message.target)")
            if message.target == rx_parent
                if network.state[rx_parent][message.origin] == LOW && message.content == HIGH && cycles_per_child[message.origin] == 0
                    cycles_per_child[message.origin] = i
                end
            end
            if all(values(cycles_per_child) .!= 0)
                return lcm([values(cycles_per_child)...])
            end
            new_messages = apply!(network, message)
            append!(message_queue, new_messages)
        end
    end
end

function apply!(network::Network, message::Message)
    new_messages = Message[]
    @match network.types[message.target] begin
        $SINK => begin end
        $BROADCAST => begin
                for child in network.network[message.target]
                    push!(new_messages, Message(message.target, child, message.content))
                end
            end
        $FLIPFLOP => begin
            if message.content == LOW
                old_state = network.state[message.target][message.target]
                new_state = invert(old_state)
                network.state[message.target][message.target] = new_state
                for child in network.network[message.target]
                    push!(new_messages, Message(message.target, child, new_state))
                end
            end
        end
        $CONJUNCTION => begin
            network.state[message.target][message.origin] = message.content
            message_content = HIGH
            if all(values(network.state[message.target]) .== HIGH)
                message_content = LOW
            end
            for child in network.network[message.target]
                push!(new_messages, Message(message.target, child, message_content))
            end
        end
    end

    new_messages
end



function node_type(str)::NODE_TYPE
    @match str begin
        "" => BROADCAST
        "%" => FLIPFLOP
        "&" => CONJUNCTION
        e => error("Invalid node type ", str)
    end
end

function Network(input_lines)
    network = Dict{Symbol, Vector{Symbol}}()
    state = Dict{Symbol, Dict{Symbol, STATE}}()
    types = Dict{Symbol, NODE_TYPE}()
    node_info = input_lines |> emptyfilter .|> parse_line
    for (name, type, children) in node_info
        network[name] = children
        types[name] = type
        state[name] = Dict()
    end

    for (name, type) in types
        if type == BROADCAST
            continue
        elseif type == FLIPFLOP
            state[name][name] = LOW
            continue
        end


        # Type == CONJUNCTION
        for (other, children) in network
            if name in children
                state[name][other] = LOW
            end
        end
    end

    for (node, children) in network
        for child in children
            if child ∉ keys(network)
                network[child] = []
                types[child] = SINK
            end
        end
    end

    Network(network, state, types)
end

function parse_line(input_line)
    re = r"([%&]?)(\w+) -> (.*)"
    m = match(re, input_line)
    name = Symbol(m[2])
    children = split(m[3], ",") .|> strip .|> Symbol
    type = node_type(m[1])
    (name, type, children)
end



# Flip Flop (%)
#
# Default: (0)
#
# (status)  -> inc :: (new status) :: sent
# (0) ->0 :: (1) -> 1
# (1) ->0 :: (0) -> 0
# (0) ->1 :: (0)
# (1) ->1 :: (1)

# Conjunction (&)
#
# Example: 3 inputs a, b, c
# Default: (0, 0, 0)
#
# -a>1 :: (1, 0, 0) -> 1
# -b>1 :: (1, 1, 0) -> 1
# -a>0 :: (0, 1, 0) -> 1
# -c>1 :: (0, 1, 1) -> 1
# -a>1 :: (1, 1, 1) -> 0

# Broadcaster (broadcaster)
#
# ->1 :: -> 1
# ->0 :: -> 0
# Button: ->0 to broadcaster

#@test part1(TESTINP1) == 32000000

#@test part1(TESTINP2) == 11687500

comparison_network = Network(
    Dict(
        :broadcaster=>[:a, :b, :c],
        :a=>[:b],
        :b=>[:c],
        :c=>[:inv],
        :inv=>[:a],
    ),
    Dict(
        :broadcaster=>Dict(),
        :a=>Dict(:a=>LOW),
        :b=>Dict(:b=>LOW),
        :c=>Dict(:c=>LOW),
        :inv=>Dict(:c=>LOW),
    ),
    Dict(
        :broadcaster=>BROADCAST,
        :a=>FLIPFLOP,
        :b=>FLIPFLOP,
        :c=>FLIPFLOP,
        :inv=>CONJUNCTION,
    )
)

@test parse_line("broadcaster -> a, b, c") == (:broadcaster, BROADCAST, [:a, :b, :c])
@test parse_line("%a -> b") == (:a, FLIPFLOP, [:b])
@test parse_line("&inv -> a") == (:inv, CONJUNCTION, [:a])

#testinp1_network = Network(split(TESTINP1, "\n"))

#@test comparison_network.network == testinp1_network.network
#@test comparison_network.types == testinp1_network.types
#@test comparison_network.state == testinp1_network.state

end # module
