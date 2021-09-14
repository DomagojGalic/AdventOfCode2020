using Test

function parseInput(path::String)
    return parse.(Int, readlines(path))
end

function guessLoopSize(initial_subject_number::Int, public_key::Int)
    subject_number = 1
    loop_size = 0

    while subject_number != public_key
        loop_size += 1
        subject_number *= initial_subject_number
        subject_number %= 20201227
    end

    return loop_size
end

function encrypt(initial_subject_number, loop_size)
    subject_number = 1
    for i in 1:loop_size
        subject_number *= initial_subject_number
        subject_number %= 20201227
    end
    return subject_number
end

function getEncryptionKey(card_subject_number::Int, door_subject_number::Int,
        card_public_key::Int, door_public_key::Int)
    card_loop_number = guessLoopSize(card_subject_number, card_public_key)
    door_loop_number = guessLoopSize(door_subject_number, door_public_key)

    encryption_key = card_loop_number < door_loop_number ? encrypt(door_public_key, card_loop_number) : encrypt(card_public_key, door_loop_number)
    return encryption_key
end

# Tests
@test guessLoopSize(7, 17807724) == 11
@test encrypt(17807724, 8) == 14897079
@test getEncryptionKey(7, 7, 5764801, 17807724) == 14897079

# Results
println("Part 1 solution: ", getEncryptionKey(7, 7, parseInput("../data/day_25_ch_1.dat")...))