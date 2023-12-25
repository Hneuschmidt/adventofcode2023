module day08mod
FILENAME = "src/inputs/day08.txt"
export day8
import ..tools: file_to_string, intparse, emptyfilter# , whitespacefilter
using Base.Iterators
using Printf

testinp="RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
"

function day8()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

struct Branch
    left::String
    right::String
end


function take_branch(instruction::Char, branch::Branch)
    if instruction == 'L'
        branch.left
    elseif instruction == 'R'
        branch.right
    else
        error("invalid instruction: ", instruction)
    end
end

function parse_branches(path_str)
    branchmap = Dict{String, Branch}()
    for line in split(path_str, "\n") |> emptyfilter
        lhs, rhs = split(line, "=")
        name = strip(lhs)
        ms = [eachmatch(r"([A-Z0-9]{3})" , rhs)...]
        left = ms[1].match
        right = ms[2].match
        branch = Branch(left, right)
        branchmap[name] = branch
    end
    branchmap
end

TEST_MAX = 5000000000
function part2(inp)
    instructions, path_str = split(inp, "\n\n")
    instructions = strip(instructions)
    branches = parse_branches(path_str)
    starts = [b for b in keys(branches) if endswith(b, "A")]
    ends = []
    println("starts: ", starts)
    step_counts = zeros(Int, length(starts))
    for (i, start) in enumerate(starts)
        steps = 0
        current = start
        # TODO use Iterators.cycle instead
        for inst in flatten(repeated(instructions))
            current = take_branch(inst, branches[current])
            steps += 1
            if endswith(current, "Z")
                push!(ends, current)
                step_counts[i] = steps
                break
            end
        end
    end
    println("ends: ", ends)
    println(step_counts)
    lcm(step_counts...)
end

function part1(inp)
    return
    # TODO make part 1 again
    instructions, path_str = split(inp, "\n\n")
    instructions = strip(instructions)
    branches = parse_branches(path_str)
    current = [b for b in keys(branches) if endswith(b, "A")]
    println("start: ", current)
    steps = 0
    # TODO use Iterators.cylce instead
    for inst in flatten(repeated(instructions))
        next = take_branch.(inst, [branches[k] for k in current])
        steps += 1
        #println(current, " -> ", next)
        current = next
        if all(endswith.(current, "Z")) || steps >= 50000000
            break
        end
    end

    steps
end

end # module
