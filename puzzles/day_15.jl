using Test

function parseStartingNumbers(path::String)
    line = readlines(path)[1]
    starting_numbers = [parse(Int, number) for number in split(line, ",")]
    return starting_numbers
end

function play(path::String, max_iteration = 2020)
    starting_numbers = parseStartingNumbers(path)
    guesses = Dict{Int, Vector{Int}}([number => [turn] for (turn, number) in enumerate(starting_numbers)])

    turn = length(starting_numbers) + 1
    last_guess = starting_numbers[end]

    while turn <= max_iteration
        #println("turn: $(turn - 1), last guess: $last_guess")
        if length(guesses[last_guess]) == 1
            last_guess = 0
        else
            turns = guesses[last_guess]
            last_guess = turns[end] - turns[end - 1]
        end
        if !(last_guess in keys(guesses))
            guesses[last_guess] = [turn]
        else
            push!(guesses[last_guess], turn)
        end
        turn += 1
    end
    #println(last_guess)
    return last_guess
end

# Tests
@test play("../data/day_15_test_1.dat") == 436
@test play("../data/day_15_test_2.dat") == 1

@test play("../data/day_15_test_1.dat", 30000000) == 175594
@test play("../data/day_15_test_2.dat", 30000000) == 2578


# Results
println("Part 1 solution: ", play("../data/day_15_ch_1.dat"))
println("Part 2 solution: ", play("../data/day_15_ch_1.dat", 30000000))