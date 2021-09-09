using Test

function parseInput(path::String)
    file = read(path, String)
    players = split(file, "\n\n")
    decks = Dict{String, Vector{Int}}()
    for player in players
        split_player = split(player, "\n")
        player_name = popfirst!(split_player)[1:(end - 1)]
        player_cards = Int[]
        for card in split_player
            push!(player_cards, parse(Int, card))
        end
        decks[player_name] = player_cards
    end

    return decks
end

function playMatch(deck_1::Vector{Int}, deck_2::Vector{Int})
    round = 0

    while !(isempty(deck_1) || isempty(deck_2))
        round += 1
        card_1 = popfirst!(deck_1)
        card_2 = popfirst!(deck_2)

        if card_1 > card_2
            append!(deck_1, [card_1, card_2])
        else
            append!(deck_2, [card_2, card_1])
        end
    end
    return isempty(deck_1) ? deck_2 : deck_1
end

function computeScore(path::String)
    decks = parseInput(path)
    winner = playMatch(decks["Player 1"], decks["Player 2"])

    score = sum(winner .* collect(length(winner):-1:1))

    return score
end

function recursiveCombat(deck_1_original::Vector{Int}, deck_2_original::Vector{Int})
    #= return true if player 1 wins, else return false =#
    deck_1 = copy(deck_1_original)
    deck_2 = copy(deck_2_original)
    
    rounds_snapshots = Vector{String}()
    round = 0

    while !(isempty(deck_1) || isempty(deck_2))
        round += 1

        round_snapshot = join(deck_1, " ") * " - " * join(deck_2, " ")
        if round_snapshot in rounds_snapshots
            return true
        else
            push!(rounds_snapshots, round_snapshot)
        end

        card_1 = popfirst!(deck_1)
        card_2 = popfirst!(deck_2)

        if card_1 <= length(deck_1) && card_2 <= length(deck_2)
            winner_recursive = recursiveCombat(deck_1[begin:card_1], deck_2[begin:card_2])
            if winner_recursive
                append!(deck_1, [card_1, card_2])
            else
                append!(deck_2, [card_2, card_1])
            end
        elseif (card_1 > card_2)
            append!(deck_1, [card_1, card_2])
        else
            append!(deck_2, [card_2, card_1])
        end
    end
    return !isempty(deck_1)
end

function playMatchRecursive(deck_1::Vector{Int}, deck_2::Vector{Int})
    rounds_snapshots = Vector{String}()
    round = 0

    while !(isempty(deck_1) || isempty(deck_2))
        round += 1

        round_snapshot = join(deck_1, " ") * " - " * join(deck_2, " ")
        if round_snapshot in rounds_snapshots
            append!(deck_1, [popfirst!(deck_1), popfirst!(deck_2)])
            continue
        else
            push!(rounds_snapshots, round_snapshot)
        end

        card_1 = popfirst!(deck_1)
        card_2 = popfirst!(deck_2)

        if card_1 <= length(deck_1) && card_2 <= length(deck_2)
            winner_recursive = recursiveCombat(deck_1[begin:card_1], deck_2[begin:card_2])
            if winner_recursive
                append!(deck_1, [card_1, card_2])
            else
                append!(deck_2, [card_2, card_1])
            end
        elseif (card_1 > card_2)
            append!(deck_1, [card_1, card_2])
        else
            append!(deck_2, [card_2, card_1])
        end
    end
    return isempty(deck_1) ? deck_2 : deck_1
end

function computeScoreRecursive(path::String)
    decks = parseInput(path)
    winner = playMatchRecursive(decks["Player 1"], decks["Player 2"])

    score = sum(winner .* collect(length(winner):-1:1))
    return score
end

# Tests
@test computeScore("../data/day_22_test_1.dat") == 306
@test computeScoreRecursive("../data/day_22_test_1.dat") == 291

# Results
println("Part 1 solution: ", computeScore("../data/day_22_ch_1.dat"))
println("Part 2 solution: ", computeScoreRecursive("../data/day_22_ch_1.dat"))