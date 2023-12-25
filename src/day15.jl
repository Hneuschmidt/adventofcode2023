module day15mod
FILENAME = "src/inputs/day15.txt"
export day15
import ..tools: file_to_string, emptyfilter, intparse_all

function day15()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

function aoc_hash(str)
    _hash(str, UInt8(0))
end

function _hash(str, cv)
    cv = ((UInt8(cv) + UInt8(str[1])) * UInt8(17))
    if length(str) <= 1
        return cv
    end

    _hash(str[2:end], cv)
end

struct Lens
    label::String
    focal_length::Int
end

struct Laser
    boxes::Vector{Vector{Lens}}
end

function parse_operation(str)
    (label, operation, focal_length) = if last(str) == '-'
            str[1:end-1], '-', -1
        else
            lb, fl = split(str, "=")
            lb, '=', parse(Int, fl)
        end
    label, operation, focal_length
end

function remove_lens!(laser::Laser, label_hash, label)
    filter!(b->b.label != label, laser.boxes[label_hash + 1])
end

function insert_lens!(laser::Laser, label_hash, label, focal_length::Int)
    box = laser.boxes[label_hash + 1]
    needle = findfirst(lens-> lens.label == label, box)
    if isnothing(needle)
        push!(laser.boxes[label_hash + 1], Lens(label, focal_length))
    else
        laser.boxes[label_hash+1][needle] = Lens(label, focal_length)
    end
    laser.boxes[label_hash + 1] 
end

function apply_job!(laser::Laser, op_string)
    label, operation, focal_length = parse_operation(op_string)
    h = aoc_hash(label)
    if operation == '-'
        remove_lens!(laser, h, label)
    else
        insert_lens!(laser, h, label, focal_length)
    end
end

function evaluate_lens_focusing_power(lens::Lens, slot)
    slot * lens.focal_length
end

function evaluate_laser_focusing_power(laser::Laser)
    acc = 0
    for (n, box) in enumerate(laser.boxes)
        lens_powers = n .* [evaluate_lens_focusing_power(lens, slot) for (slot, lens) in enumerate(box)]
        acc += sum(lens_powers)
    end
    acc
end

function part1(inp)
    split(strip(inp), ",") .|> aoc_hash .|> Int |> sum
end

function part2(inp)
    laser = Laser([Vector{Lens}() for _ in 1:256])
    # constructing laser
    split(strip(inp), ",") .|> (op_string-> apply_job!(laser, op_string))
    evaluate_laser_focusing_power(laser)
end


end # module
