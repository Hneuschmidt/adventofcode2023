module day05mod
FILENAME = "src/inputs/day05.txt"
export day5
import ..tools: file_to_string, intparse, emptyfilter

struct Map
    name::String
    in_ranges::Vector{UnitRange{Int64}}
    out_ranges::Vector{UnitRange{Int64}}
end

function Map(descr)
    name, ranges = split(descr, ":")
    in_ranges = UnitRange{Int64}[]
    out_ranges = UnitRange{Int64}[]

    for range in split(ranges, "\n")
        if isempty(range) continue end
        numbers = split(range, " ")
        dest_start = parse(Int, numbers[1])
        source_start = parse(Int, numbers[2])
        len = parse(Int, numbers[3])
        push!(in_ranges, source_start:(source_start+len))
        push!(out_ranges, dest_start:(dest_start+len))
    end

    Map(name, in_ranges, out_ranges)
end

function day5()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

function go_through(m::Map, num)
    for (i, in_range) in enumerate(m.in_ranges)
        if num in in_range
            delta = num - first(in_range)
            return first(m.out_ranges[i]) + delta
        end
    end

    num
end

function part1(inp)
    seed_descriptions, map_descriptions = split(inp, "\n\n", limit=2)
    seeds = split(seed_descriptions[8:end]) .|> intparse
    maps = Map.(split(map_descriptions, "\n\n") |> emptyfilter)
    location_numbers(seeds, maps)
end

function location_number(seed, maps)
    for amap in maps
        seed = go_through(amap, seed)
    end
    seed
end

function location_numbers(seeds, maps)
    locations = zeros(Int, length(seeds))

    for (i, seed) in enumerate(seeds)
        for amap in maps
            seed = go_through(amap, seed)
        end
        locations[i] = seed
    end

    minimum(locations)
end

function part2(inp)
    seed_descriptions, map_descriptions = split(inp, "\n\n", limit=2)
    seed_info = split(seed_descriptions[8:end]) .|> intparse
    maps = Map.(split(map_descriptions, "\n\n") |> emptyfilter)
    res = typemax(Int)
    #println("seed info: ", seed_info)
    for idx in 1:2:length(seed_info)
        start = seed_info[idx]
        len = seed_info[idx+1]

        #println("start: ", start, "len: ", len)
        seeds = start:(start+len)
        println("seeds: ", seeds)
        for seed in seeds
            loc = location_number(seed, maps)
            if loc < res
                res = loc
            end
        end
    end
    res
end


function mapnext(num, map)
end

example_map = "seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 46
"
end # module
