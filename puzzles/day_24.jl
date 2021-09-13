using Test
using DataStructures
using LinearAlgebra


function prettyfy(x::Float64, digits = 4)
    y = round(x, digits = digits)
    return y ≈ .0 ? .0 : y
end


function parseTile(line::String)
    tile_dict = DefaultDict{String, Int}(0)
    line_length = length(line)
    pos = [0, 0]
    
    i = 1
    while i <= line_length
        if line[i] == 'e'
            pos += [1, 0]
        elseif line[i] == 'w'
            pos += [-1, 0]
        elseif line[i] == 'n'
            if line[i + 1] == 'e'
                pos += [.5, sqrt(3)/2]
            else
                pos += [-.5, sqrt(3)/2]
            end
            i += 1
        elseif line[i + 1] == 'e'
            pos += [.5, -sqrt(3)/2]
            i += 1
        else
            pos += [-.5, -sqrt(3)/2]
            i += 1
        end 
        i += 1
    end

    return pos
end

function parseInput(path::String)
    tiles = Vector{Vector{Float64}}()
    for line in readlines(path)
        push!(tiles, parseTile(line))
    end

    return tiles
end

function getCoordinates(tiles::Vector{Tuple{NTuple{3, Int}, Vector{Float64}}})
    coord_dict = Dict{String, Vector{Float64}}()

    for pos in tiles
        string_pos = (x -> "$(x[1]) $(x[2])")(prettyfy.(pos))
        coord_dict[string_pos] = pos
    end
    return coord_dict
end

function getTileColor(tiles::Vector{Vector{Float64}})
    black_dict_pos = DefaultDict{String, Bool}(false)

    for pos in tiles
        string_pos = (x -> "$(x[1]) $(x[2])")(prettyfy.(pos))
        black_dict_pos[string_pos] = !black_dict_pos[string_pos]
    end
    return black_dict_pos
end

function countBlackTiles(path::String)
    tiles = parseInput(path)
    black_dict_pos = getTileColor(tiles)

    return sum(values(black_dict_pos))
end

function getNeighbours(coord_dict::Dict{String, Vector{Float64}})
    neighbours_dict = Dict{String, Vector{String}}()

    for (str_pos, pos) in coord_dict
        current_neighbours = Vector{String}()
        for (n_str_pos, n_pos) in coord_dict
            if str_pos == n_str_pos
                continue
            end
            if norm(n_pos - pos) <= 1.01
                push!(current_neighbours, n_str_pos)
            end
        end
        neighbours_dict[str_pos] = current_neighbours
    end
    return neighbours_dict
end

function getAdjecantTiles(pos::Vector{Float64})
    e = pos + [1, 0]
    w = pos + [-1, 0]
    ne = pos + [.5, sqrt(3)/2]
    nw = pos + [-.5, sqrt(3)/2]
    se = pos + [.5, -sqrt(3)/2]
    sw = pos + [-.5, -sqrt(3)/2]

    return (pos, e, w, ne, nw, se, sw)
end

function colorSwitch(tiles_dict::Dict{String, Vector{Float64}}, colors_dict::Dict{String, Bool})
    new_tiles = Dict{String, Vector{Float64}}()
    
    for (tile_id, position) in tiles_dict
        for pos in getAdjecantTiles(position)
            string_pos = (x -> "$(x[1]) $(x[2])")(prettyfy.(pos))
            if !(string_pos in keys(new_tiles))
                new_tiles[string_pos] = pos
            end
        end
    end

    neighbours_dict = getNeighbours(new_tiles)
    new_colors_dict = Dict{String, Bool}()

    for (tile_id, neighbours_list) in neighbours_dict
        black_neighbours = sum([colors_dict[tile] for tile in neighbours_list if tile in keys(colors_dict)])

        if !(tile_id in keys(colors_dict))
            if black_neighbours == 2
                new_colors_dict[tile_id] = true
            end
        else
            if (colors_dict[tile_id] && (0 < black_neighbours <= 2)) || (!colors_dict[tile_id] && black_neighbours == 2)
                new_colors_dict[tile_id] = true
            end
        end
    end

    return Dict([key => new_tiles[key] for key in keys(new_tiles)]), new_colors_dict
end

function iterate(path::String, rounds::Int)
    tiles = parseInput(path)
    coord_dict = getCoordinates(tiles)
    color_dict = Dict(getTileColor(tiles))

    for i in 1:rounds
        coord_dict, color_dict = colorSwitch(coord_dict, color_dict)
        if i % 10 == 0
            println("round $i")
        end
    end

    return sum(values(color_dict))
end

# Tests
@test countBlackTiles("../data/day_24_test_1.dat") == 10
@test iterate("../data/day_24_test_1.dat", 10) == 37
@test iterate("../data/day_24_test_1.dat", 20) == 132

# Results
println("Part 1 solution: ", countBlackTiles("../data/day_24_ch_1.dat"))
println("Part 2 solution: ", iterate("../data/day_24_ch_1.dat", 100))