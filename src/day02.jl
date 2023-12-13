module day02mod
FILENAME = "src/inputs/day02.txt"
export day2
import ..tools: file_to_string

struct CubeSet
    red::UInt
    green::UInt
    blue::UInt
end

function CubeSet(ary::AbstractArray)
    CubeSet(ary[1], ary[2], ary[3])
end

function array(cs::CubeSet)
    [cs.red, cs.green, cs.blue]
end

function power(cs::CubeSet)
    cs.red * cs.green * cs.blue
end

function day2()
    input = file_to_string(FILENAME)
    println("Part 1: ", part1(input))
    println("Part 2: ", part2(input))
end
    
function part1(games)
    possible_cubes = day02mod.CubeSet(12, 13, 14)
    possible_game_ids(possible_cubes, games) |> sum
end 

function maximum_draws(game)
    game_cubes = [0, 0, 0];
    patterns = [r"(\d+)( red)", r"(\d+)( green)", r"(\d+)( blue)"]
    for draw in split(game, ';')
        for (i, pattern) in enumerate(patterns)
            m = match(pattern, draw)
            if !isnothing(m)
                n =  parse(UInt, m.captures[1])
                if n > game_cubes[i]
                    game_cubes[i] = n
                end
            end
        end
    end
    
    game_cubes
end

function is_game_possible(cubes, game)
    if isempty(game)
        return false
    end

    game_cubes = maximum_draws(game)

    all(x->x!=0, game_cubes .<= array(cubes))
end

function extract_id(game)
    m = match(r"(Game )(\d+):", game)
    parse(UInt, m.captures[2])
end

function possible_game_ids(cubes, games)
    test_game(game) = is_game_possible(cubes, game)
    game_filter(games) = filter(test_game, games)

    split(games, '\n') |> game_filter .|> extract_id
end

# part2

function part2(games)
    split(games, '\n') .|> maximum_draws .|> CubeSet .|> power |> sum
end 

end # module
