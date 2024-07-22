module day19mod
FILENAME = "src/inputs/day19.txt"
export day19
import ..tools: file_to_string, emptyfilter, intparse_all

using Match

function day19()
    inp = file_to_string(FILENAME)
    println(part1(inp))
    println(part2(inp))
end

function part1(inp)
    parts, workflows = split_parts_workflows(inp)
    accepted = 0
    acc = 0
    state = :in

    for part in parts
        while state ∉ [:accepted, :rejected]
            state = apply(workflows[state], part)
        end
        @match state begin
            :accepted => begin accepted += 1; acc += sum(part) end
            :rejected => begin end
        end
        state = :in
    end

    return acc
end

function part2(inp)
    _, workflows = split_parts_workflows(inp)
    ranges = [(PartRange(), :in)]
    accepted = 0
    while !isempty(ranges)
        range, state = pop!(ranges)
        wf = workflows[state]
        @match wf.name begin
            :A => begin accepted += sum(range); continue end
            :R => continue
            _ => begin end
        end


        for rule in wf.rules
            new_ranges = split_at_rule(range, rule)

            for (new_range, next) in new_ranges
                if next == :passthrough
                    range = new_range  
                    state = next
                else
                    push!(ranges, (new_range, next))
                end
            end

        end
    end


    return accepted
end

struct Part
    x::Int
    m::Int
    a::Int
    s::Int
end

struct PartRange
    x::UnitRange{Int64}
    m::UnitRange{Int64}
    a::UnitRange{Int64}
    s::UnitRange{Int64}
end

function PartRange()
    PartRange(1:4000, 1:4000, 1:4000, 1:4000)
end

function PartRange(d::Dict)
    PartRange(d[:x], d[:m], d[:a], d[:s])
end

function sum(range::PartRange)
    Int128(length(range.x)) * length(range.m) * length(range.a) * length(range.s)
end

function to_dict(p::PartRange)
    Dict(:x=>p.x, :m=>p.m, :a=>p.a, :s=>p.s)
end

function Part(part_str)
    re = r"{x=(\d+),m=(\d+),a=(\d+),s=(\d+)}"
    m = match(re, part_str)
    parseint(x) = parse(Int, x)
    if isnothing(m)
        error("match is empty: (", part_str, ")")
    end
    vals = parseint.(m.captures)
    Part(vals[1], vals[2], vals[3], vals[4])
end

@enum RuleType GT LT ACCEPT REJECT PASSTHRU


function sum(part::Part)
    part.x + part.m + part.a + part.s
    
end

struct Rule
    field::Symbol
    threshold::Int
    type::RuleType
    next::Symbol
end

function Rule(rule_str)
    if rule_str == "A"
        return Rule(:NA, -1, ACCEPT, :NA)
    elseif rule_str == "R"
        return Rule(:NA, -1, REJECT, :NA)
    elseif isnothing(match(r"[<>=]", rule_str))
        return Rule(:NA, -1, PASSTHRU, Symbol(rule_str))
    end

    re = r"([xmas])([<>=])(\d+):(\w+)"
    field_str, type_str, threshold_str, next_str = match(re, rule_str)
    type = @match type_str begin
        ">" => GT
        "<" => LT
    end
    Rule(Symbol(field_str), parse(Int, threshold_str), type, Symbol(next_str))
end


struct Workflow
    name::Symbol
    rules::Vector{Rule}
end


function Workflow(part_str)
    name_re = r"(\w+){(.*)}"
    name_m = match(name_re, part_str)
    name = Symbol(name_m[1])
    rule_strs = split(name_m[2], ",")
    rules = [Rule(rule_str) for rule_str in rule_strs]
    Workflow(name, rules)
end


function apply(part::Part, rule::Rule)
    op = @match rule.type begin
        $ACCEPT => begin return :accepted end
        $REJECT => begin return :rejected end
        $PASSTHRU => begin return rule.next end
        $GT => >
        $LT => <
    end

    val = getfield(part, rule.field)

    if op(val, rule.threshold)
        return rule.next
    else
        return :continue
    end
end

function apply(wf::Workflow, part::Part)
    state = :continue
    for rule in wf.rules
        state = apply(part, rule)
        if state != :continue
            return state
        end
    end

    error("Not accepted or rejected after apply")
end


function split_parts_workflows(inp)
    workflow_string, part_string = split(inp, "\n\n")
    parts = [Part(s) for s in split(part_string, "\n")[1:end-1]]
    workflows = [Workflow(s) for s in split(workflow_string, "\n")]
    workflow_dict = Dict((wf.name, wf) for wf in workflows)
    workflow_dict[:A] = Workflow(:A, [Rule(:NA, -1, ACCEPT, :NA)])
    workflow_dict[:R] = Workflow(:R, [Rule(:NA, -1, REJECT, :NA)])

    return [parts, workflow_dict]
end

# struct Rule
#     field::Symbol
#     threshold::Int
#     type::RuleType
#     next::Symbol
# end


function split_at_rule(r::PartRange, rule::Rule)
    @match rule.type begin
        $GT => split_gt(r, rule)
        $LT => split_lt(r, rule)
        $PASSTHRU => split_passthrough(r, rule)
        $REJECT => split_reject(r, rule)
        $ACCEPT => split_accept(r, rule)
        t => error("wrong range type: ", t)
    end
end


function split_accept(range::PartRange, rule::Rule)
    [(range, :A)]
end


function split_reject(range::PartRange, rule::Rule)
    [(range, :R)]
end


function split_gt(range::PartRange, rule::Rule)
    threshold = rule.threshold
    range_dict = to_dict(range)
    l = first(range_dict[rule.field])
    u = last(range_dict[rule.field])

    passthrough_range = l:threshold
    switch_range = threshold+1:u

    passthrough_dict = copy(range_dict)
    switch_dict = copy(range_dict)

    passthrough_dict[rule.field] = passthrough_range
    switch_dict[rule.field] = switch_range

    [(PartRange(passthrough_dict), :passthrough), (PartRange(switch_dict), rule.next)]
end

function split_lt(range::PartRange, rule::Rule)
    threshold = rule.threshold
    range_dict = to_dict(range)
    l = first(range_dict[rule.field])
    u = last(range_dict[rule.field])

    passthrough_range = threshold:u
    switch_range = l:threshold-1

    passthrough_dict = copy(range_dict)
    switch_dict = copy(range_dict)

    passthrough_dict[rule.field] = passthrough_range
    switch_dict[rule.field] = switch_range

    [(PartRange(passthrough_dict), :passthrough), (PartRange(switch_dict), rule.next)]
end

function split_passthrough(range::PartRange, rule::Rule)
    [(range, rule.next)]
end

end # module
