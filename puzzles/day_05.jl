using Test

struct SeatPosition
    binary_space_partitioning::String
    row::Int64
    column::Int64
    seat_id::Int64
end

function SeatPosition(binary_space_partitioning::String)
    upper = 127
    lower = 0
    for position in binary_space_partitioning[1:7]
        mid = upper - lower
        if position == 'F'
            upper = lower + mid ÷ 2
        elseif position == 'B'
            lower = lower + mid ÷ 2 + 1
        end
        #println("upper: ", upper, ", lower: ", lower)
    end
    row = upper <= lower ? upper : lower

    #println("\ncolumns:")

    upper = 7
    lower = 0
    for position in binary_space_partitioning[8:end]
        mid = upper - lower
        if position == 'L'
            upper = lower + mid ÷ 2
        elseif position == 'R'
            lower = lower + mid ÷ 2 + 1
        end
        #println("upper: ", upper, ", lower: ", lower)
    end
    column = upper <= lower ? upper : lower
    seat_id = row*8 + column

    SeatPosition(binary_space_partitioning, row, column, seat_id)
end


function parseBoardingPasses(path::String)
    lines = readlines(path)
    boarding_passes = [SeatPosition(line) for line in lines]

    return boarding_passes
end

function getMaximalSeatID(path::String)
    boarding_passes = parseBoardingPasses(path)
    return maximum([seat_position.seat_id for seat_position in boarding_passes])
end

function getYourSeatID(path::String)
    boarding_passes = parseBoardingPasses(path)
    taken_seats = sort([seat_position.seat_id for seat_position in boarding_passes])
    before = (taken_seats[1:(end - 1)])[(diff(taken_seats) .- 1) .== 1]

    return before .+ 1
end


# Tests
sp = SeatPosition("BFFFBBFRRR")
@test sp.row == 70
@test sp.column == 7
@test sp.seat_id == 567
sp = SeatPosition("FFFBBBFRRR")
@test sp.row == 14
@test sp.column == 7
@test sp.seat_id == 119
sp = SeatPosition("BBFFBBFRLL")
@test sp.row == 102
@test sp.column == 4
@test sp.seat_id == 820


# Results
println("Part 1 solution: ", getMaximalSeatID("../data/day_05_ch_1.dat"))
println("Part 2 solution: ", getYourSeatID("../data/day_05_ch_1.dat"))
