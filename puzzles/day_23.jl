using Test

struct Circle
    current::Vector{Int}
    next::Vector{Int}
end

function customMod(x::Int, y::Int)
    result = mod(x, y)
    return result == 0 ? y : result
end

function Circle(initial_cups::Vector{Int})
    no_initial = length(initial_cups)
    no_cups = 10^6
    current = initial_cups[1]
    getIndex = x -> findfirst(y -> y == customMod(x, no_initial), initial_cups)

    next = [[initial_cups[customMod(getIndex(i) + 1, no_initial)] for i in 1:no_initial];
            collect((no_initial + 2):(no_cups + 1))]
    next[no_cups] = current
    next[initial_cups[end]] = no_initial + 1

    return Circle([current], next)
end

function parseInput(values::String)
    return parse.(Int, [value for value in values])
end

function rotateArround(x::Vector{T}, ind::Int) where T
    if ind == length(x)
        return x
    else
        return [x[(ind + 1):end]; x[1:ind]]
    end
end

function makeMove(cups::Vector{Int})
    n_cups = length(cups)
    current_cup = popfirst!(cups)
    removed_cups = cups[1:3]
    remaining_cups = [cups[4:end]; current_cup]

    destination_cup = customMod(current_cup - 1, n_cups)
    while !(destination_cup in remaining_cups)
        destination_cup = customMod(destination_cup - 1, n_cups)
    end

    destination_index = findfirst(x -> x == destination_cup, remaining_cups)
    rotated_cups = [rotateArround(remaining_cups, destination_index); removed_cups]

    return rotateArround(rotated_cups, findfirst(x -> x == current_cup, rotated_cups))
end

function makeMove!(cups::Circle)
    current = cups.current[1]
    taken_1 = cups.next[current]
    taken_2 = cups.next[taken_1]
    taken_3 = cups.next[taken_2]
    next_current = cups.next[taken_3]

    cups.next[current] = next_current
    no_cups = length(cups.next)
    destination = customMod(current - 1, no_cups)
    while destination in (taken_1, taken_2, taken_3)
        destination = customMod(destination - 1, no_cups)
    end
    next_destination = cups.next[destination]

    cups.next[destination] = taken_1
    cups.next[taken_3] = next_destination
    
    cups.current[1] = next_current
    
    return nothing
end

function play(cups::Vector{Int}, rounds::Int)
    for i in 1:rounds
        cups = makeMove(cups)
    end
    return join(rotateArround(cups, findfirst(x -> x == 1, cups))[1:(end - 1)], "")
end

function play!(cups::Circle, rounds::Int)
    for i in 1:rounds
        makeMove!(cups)
    end
    
    after_one = cups.next[1]
    return after_one * cups.next[after_one]
end 


# Tests
@test play(parseInput("389125467"), 10) == "92658374"
@test play(parseInput("389125467"), 100) == "67384529"

# Results
println("Part 1 solution: ", play(parseInput("193467258"), 100))
println("Part 2 solution: ", play!(Circle(parseInput("193467258")), 10^7))
