using Base: Int64, current_logger, multiplicativeinverse
using Test
using DelimitedFiles

mutable struct TobogganPosition
    move_horizontal::Int64
    move_vertical::Int64

    position_horizontal::Int64
    position_vertical::Int64

    data::Matrix{Char}
    data_hight::Int64
    data_width::Int64
end

function TobogganPosition(move_horizontal::Int64,
    move_vertical::Int64, data::Matrix{Char})
    data_hight, data_width = size(data)
    TobogganPosition(move_horizontal, move_vertical, 1, 1, data, data_hight, data_width)
end

function move!(tobogan_position::TobogganPosition)
    position_horizontal = tobogan_position.move_horizontal + tobogan_position.position_horizontal
    position_vertical = tobogan_position.move_vertical + tobogan_position.position_vertical

    if position_vertical > tobogan_position.data_hight
        return false
    end

    tobogan_position.position_horizontal = position_horizontal
    tobogan_position.position_vertical = position_vertical

    return true
end

function getStepValue(tobogan_position::TobogganPosition)

    index_horizontal = (tobogan_position.position_horizontal - 1) % tobogan_position.data_width + 1
    index_vertical = tobogan_position.position_vertical

    return tobogan_position.data[index_vertical, index_horizontal]
end


function parseMap(path::String)
    lines = readlines(path)
    data = Matrix{Char}(undef, length(lines), length(lines[1]))
    for (m, line) in enumerate(lines)
        for (n, letter) in enumerate(line)
            data[m, n] = letter
        end
    end
    return data
end


function countTrees(path::String, horizontal_movement = 3, vertical_movement = 1)
    data = parseMap(path)

    toboggan_position = TobogganPosition(horizontal_movement, vertical_movement, data)
    trees_counter = 0

    while move!(toboggan_position)
        current_value = getStepValue(toboggan_position)
        if current_value == '#'
            trees_counter += 1
        end
    end
    return trees_counter
end

function multiplyTreeCount(path::String, movements::Vector{Tuple{Int64, Int64}})
    trees_encountered = [countTrees(path, horizontal, vertical) for (horizontal, vertical) in movements]
    return prod(trees_encountered)
end

# Test
@test countTrees("../data/day_03_test_1.dat") == 7
@test multiplyTreeCount("../data/day_03_test_1.dat", [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]) ==  336


# Results
println("Part 1 solution: ", countTrees("../data/day_03_ch_1.dat"))
println("Part 2 solution: ", multiplyTreeCount("../data/day_03_ch_1.dat", [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]))