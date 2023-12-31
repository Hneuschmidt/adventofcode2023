module day17mod
FILENAME = "src/inputs/day17.txt"
export day17
import ..tools: file_to_string, emptyfilter, intparse_all
using StaticArrays
using Match
using DataStructures
using Debugger
using Infiltrator

@enum DIRECTION NORTH SOUTH EAST WEST NONE

struct State
    idx::CartesianIndex{2}
    dir::DIRECTION
    steps_taken::Int
end

function day17()
    input = file_to_string(FILENAME)
    println(part1(input))
    println(part2(input))
end

function get_neighbours(grid, idx, unvisited, forbidden)
    r, c = Tuple(idx)
    rows, cols = axes(grid)
    neighbour_list = CartesianIndex{2}[]

    for (Δr, Δc) in [(-1, 0), (1, 0), (0, -1), (0, 1)]
        new_idx = (r + Δr, c + Δc)
        # TODO extra check for (r, c) needed? Or do I only call this with visited (r, c)?
        if CartesianIndex(new_idx) ∈ setdiff(unvisited, forbidden)
            push!(neighbour_list, CartesianIndex(new_idx))
        end
    end
    neighbour_list

end


function opposite(dir::DIRECTION)
    @match dir begin
        $NORTH => SOUTH
        $SOUTH => NORTH
        $EAST => WEST
        $WEST => EAST
        $NONE => NONE
    end
end


function get_neighbours(state::State, unvisited, last::State)
    r, c = Tuple(state.idx)
    neighbour_list = State[]

    for (dir, Δr, Δc) in [(NORTH, -1, 0), (SOUTH, 1, 0), (WEST, 0, -1), (EAST, 0, 1)]
        new_idx = CartesianIndex(r + Δr, c + Δc)
        if dir == opposite(state.dir)
            continue
        end
        new_state = State(new_idx, dir, state.dir == dir ? state.steps_taken +1 : 1)
        if new_state ∈ unvisited
            push!(neighbour_list, new_state)
        end
    end

    neighbour_list
end

function get_neighbours_part2(state::State, unvisited, last::State)
    r, c = Tuple(state.idx)
    neighbour_list = State[]

    for (dir, Δr, Δc) in [(NORTH, -1, 0), (SOUTH, 1, 0), (WEST, 0, -1), (EAST, 0, 1)]
        new_idx = CartesianIndex(r + Δr, c + Δc)
        if dir == opposite(state.dir)
            continue
        end
        if state.dir != NONE && (dir != state.dir && state.steps_taken < 4)
            continue
        end
        new_state = State(new_idx, dir, state.dir == dir ? state.steps_taken +1 : 1)
        if new_state ∈ unvisited
            push!(neighbour_list, new_state)
        end
    end

    neighbour_list
end


function three_previous_steps_same_direction(previous, idx, Δ)
    orig = CartesianIndex(0, 0)
    p1 = get(previous, idx, orig)
    p2 = get(previous, p1, orig)
    p3 = get(previous, p2, orig)
    if any([p1, p2, p3] .== orig)
        return false
    end

    step1 = idx - p1
    step2 = p1 - p2
    step3 = p2 - p3

    step1 == step2 && step1 == step3 && step1 == Δ
end

function grid_bellmann_ford(grid, idx)
    distance = similar(grid, Float64)
    distance .= Inf64
    previous = similar(grid, CartesianIndex{2})
    previous .= CartesianIndex(0, 0) # fake index

    distance[idx] = 0.0

    # relax edges
    for _ in 1:length(grid)
        for u in eachindex(IndexCartesian(), grid)
            for v in get_neighbours(grid, u)
                # TODO Should also check if we are going back
                if distance[u] + grid[v] < distance[v]
                    Δ = v - u
                    # TODO assumes that the previous steps are already set in stone but they are not
                    if !three_previous_steps_same_direction(previous, u, Δ)
                        distance[v] = distance[u] + grid[v]
                        previous[v] = u
                    end
                end
            end
        end
    end

    distance, previous
end

function visualize_distances(grid, distances)
    min_dists = Dict{CartesianIndex{2}, Float64}()
    for (k, v) in distances
        idx = k.idx
        if v < get(min_dists, idx, Inf64)
            min_dists[idx] = v
        end
    end
    marked_grid = similar(grid, String)
    for idx in eachindex(IndexCartesian(), grid)
        d = get(min_dists, idx, Inf64)
        dc = string(d)
        if dc == "Inf"
            dc = "."
        end
        marked_grid[idx] = dc
    end
    marked_grid
    #join([String(marked_grid[r, :]) for r in 1:size(grid)[1]], "\n")
end

function grid_dijkstra_part2(grid, idx)
    # initialization
    state = State(CartesianIndex(idx), NONE, 0)
    unvisited = Set([State(arg...) for arg in Iterators.product(eachindex(IndexCartesian(), grid), [NORTH, SOUTH, EAST, WEST], 1:10)])
    starting_states = Set([State(arg...) for arg in Iterators.product(Ref(CartesianIndex(1, 1)), [NORTH, SOUTH, EAST, WEST], 1:10)])

    setdiff!(unvisited, starting_states)
    #union!(unvisited, Set([state]))

    pq = PriorityQueue([n=>Inf for n in unvisited])
    pq[state] = 0.0
    distances = Dict([state=>0.0])
    previous = Dict{State, State}()
    # TODO sometimes inf
    while !isempty(pq)
        state = dequeue!(pq)

        for neighbour_state in get_neighbours_part2(state, unvisited, get(previous,state, State(CartesianIndex(-1, -1), NONE, 0)))
            old_dist = get(distances, neighbour_state, Inf64)

            new_dist = get(distances,state, Inf64) + grid[neighbour_state.idx]
            if new_dist < old_dist
                distances[neighbour_state] = new_dist
                previous[neighbour_state] = state
                pq[neighbour_state] = new_dist
            end
        end
    end

    distances, previous
end

# TODO move out the states from the algorithm so part1 and part2 use the same implementation
function grid_dijkstra(grid, idx)
    # initialization
    state = State(CartesianIndex(idx), NONE, 0)
    unvisited = Set([State(arg...) for arg in Iterators.product(eachindex(IndexCartesian(), grid), [NORTH, SOUTH, EAST, WEST], 1:3)])
    starting_states = Set([State(arg...) for arg in Iterators.product(Ref(CartesianIndex(1, 1)), [NORTH, SOUTH, EAST, WEST], 1:3)])

    setdiff!(unvisited, starting_states)
    #union!(unvisited, Set([state]))

    pq = PriorityQueue([n=>Inf for n in unvisited])
    pq[state] = 0.0
    distances = Dict([state=>0.0])
    previous = Dict{State, State}()
    # TODO sometimes inf
    while !isempty(pq)
        s, p = peek(pq)
        state = dequeue!(pq)

        for neighbour_state in get_neighbours(state, unvisited, get(previous,state, State(CartesianIndex(-1, -1), NONE, 0)))
            old_dist = get(distances, neighbour_state, Inf64)

            new_dist = get(distances,state, Inf64) + grid[neighbour_state.idx]
            if new_dist < old_dist
                distances[neighbour_state] = new_dist
                previous[neighbour_state] = state
                pq[neighbour_state] = new_dist
            end
        end
    end

    distances, previous
end

function retrace_part2(prev, start::CartesianIndex{2}, dest::State)
    current = dest
    steps = typeof(dest)[]
    push!(steps, current)
    while current.idx != start
        current = get(prev,current, missing)
        if ismissing(current)
            return false, steps
        end
        push!(steps, current)
    end
    
    reverse!(steps)
    true, steps
end

function retrace(prev, start::CartesianIndex{2}, dest::State)
    current = dest
    steps = typeof(dest)[]
    push!(steps, current)
    while current.idx != start
        current = prev[current]
        push!(steps, current)
    end
    
    reverse!(steps)
    steps
end

function destination_cost_part2(dest_idx, distances, prev)
    dest_states = [State(arg...) for arg in Iterators.product(Ref(dest_idx), [NORTH, SOUTH, EAST, WEST], 1:10)]
    dest_distances = fill(Inf64, length(dest_states))
    for (i, state) in enumerate(dest_states)
        dest_distances[i] = get(distances, state, Inf64)
    end

    min_path_idx = argmin(dest_distances)

    retrace_part2(prev, CartesianIndex(1,1), dest_states[min_path_idx])
end

function destination_cost(dest_idx, distances, prev)
    dest_states = [State(arg...) for arg in Iterators.product(Ref(dest_idx), [NORTH, SOUTH, EAST, WEST], 1:3)]
    dest_distances = zeros(Float64, length(dest_states))
    for (i, state) in enumerate(dest_states)
        dest_distances[i] = get(distances, state, Inf64)
    end

    min_path_idx = argmin(dest_distances)

    retrace(prev, CartesianIndex(1,1), dest_states[min_path_idx])
end

function visualize_path(grid::Matrix{Char}, steps)
    marked_grid = copy(grid)
    for idx in eachindex(IndexCartesian(), grid)
        if idx in [s.idx for s in steps]
            marked_grid[idx] = '.'
        end
    end
    marked_grid
    join([String(marked_grid[r, :]) for r in 1:size(grid)[1]], "\n")
end

function str_to_char_grid(str)
    n_columns = first(findfirst('\n', str)) - 1
    lines = split(str, '\n') |> emptyfilter
    n_rows = length(lines)
    tiles = Matrix{Char}(undef, n_rows, n_columns)
    for (r,line) in enumerate(lines)
        tiles[r, :] .= Vector{Char}(line)
    end

    tiles
end

function part1(inp) 
    char_grid = str_to_char_grid(strip(inp))
    int_grid = parse.(Int, char_grid)
    start = CartesianIndex(1, 1)
    dest = CartesianIndex(size(char_grid))
    dist, prev = grid_dijkstra(int_grid, start)
    #println(dest)
    #dist, prev = grid_bellmann_ford(int_grid, start)
    steps = destination_cost(dest, dist, prev)
    println(visualize_path(char_grid, steps))
    println()
    dist[steps[end]]
    #steps
end

function part2(inp)
    char_grid = str_to_char_grid(strip(inp))
    int_grid = parse.(Int, char_grid)
    start = CartesianIndex(1, 1)
    dest = CartesianIndex(size(char_grid))
    dist, prev = grid_dijkstra_part2(int_grid, start)
    _, steps = destination_cost_part2(dest, dist, prev)
    println(visualize_path(char_grid, steps))
    println()
    dist[steps[end]]
    #steps
end

easyinp = "11111
24441
44441
44441
44441"

testinp = "2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533"

end # module
