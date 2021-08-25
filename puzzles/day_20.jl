using Test
using DataStructures

function parseInput(path::String)
    raw_tiles = split(read(path, String), "\n\n")

    tile_dict = Dict{String, Matrix{Char}}()

    for tile in raw_tiles
        tile_rows = split(tile, "\n")
        tile_name = string((split(tile_rows[1])[2])[1:(end - 1)])
        tile_body = tile_rows[2:end]

        tile_size = length(tile_body[1])
        tile_matrix = Matrix{Char}(undef, tile_size, tile_size)

        for (n, tile_body_row) in enumerate(tile_body)
            tile_matrix[n, :] = [i[1] for i in split(tile_body_row, "")]
        end

        tile_dict[tile_name] = tile_matrix
    end
    return tile_dict
end

function getBorders(tile::Matrix{Char})
    tile_borders = join.([tile[1, :], tile[end, :], tile[:, 1], tile[:, end]], "")
    return tile_borders
end

function matchTiles(first_tile::Matrix{Char}, second_tile::Matrix{Char})
    borders_first = getBorders(first_tile)
    borders_second = getBorders(second_tile)

    for border_first in borders_first
        for border_second in borders_second
            if border_first == border_second || border_first == border_second[end:-1:1]
                return true
            end
        end
    end
    return false
end

function distributionOfMatches(tile_dict::Dict{String, Matrix{Char}})
    tile_keys = collect(keys(tile_dict))
    tile_number = length(tile_keys)

    match_dict = DefaultDict{String, Int}(0)

    for i in 1:(tile_number - 1)
        for j in (i + 1):tile_number
            increment = matchTiles(tile_dict[tile_keys[i]], tile_dict[tile_keys[j]])
            match_dict[tile_keys[i]] += increment
            match_dict[tile_keys[j]] += increment
        end
    end
    return match_dict
end

function productOfCorners(match_dict::DefaultDict{String, Int, Int})
    return prod([parse(Int, key) for (key, value) in match_dict if value == 2])
end

function getFinalProduct(path::String)
    tile_dict = parseInput(path)
    match_dict = distributionOfMatches(tile_dict)
    return productOfCorners(match_dict)
end

function positionTile(main_tile::Matrix{Char}, second_tile::Matrix{Char})
    if all(main_tile[:, end] .== second_tile[:, 1])
        return (1, 0)
    elseif all(main_tile[:, 1] .== second_tile[:, end])
        return (-1, 0)
    elseif all(main_tile[end, :] == second_tile[1, :])
        return (0, -1)
    elseif all(main_tile[1, :] .== second_tile[end, :])
        return (0, 1)
    else
        return (0, 0)
    end
end

function rotateMatrixPositive(tile::Matrix{Char})
    return permutedims(tile[:, end:-1:1])
end

function rotateMatrixNegative(tile::Matrix{Char})
    return permutedims(tile[end:-1:1, :])
end

function getTileRotations(tile::Matrix{Char})
    tile_rotations = Vector{Matrix{Char}}()
    current_tile = tile
    for _ in 1:4
        push!(tile_rotations, current_tile)
        current_tile = rotateMatrixPositive(current_tile)
    end
    return tile_rotations
end

function tileVariations(tile::Matrix{Char})
    tile_variations = Vector{Matrix{Char}}()
    rotated_variations = map(getTileRotations, [tile, tile[end:-1:1, :]])
    [append!(tile_variations, rotated_tile) for rotated_tile in rotated_variations]
    return tile_variations
end


function makeTileArangement(tiles_dict::Dict{String, Matrix{Char}})
    tile_pairs = [(key, value) for (key, value) in tiles_dict]
    number_of_tiles = length(tile_pairs)
    matched_tiles = Dict{Tuple{Int, Int}, Matrix{Char}}()
    matched_tiles_rotated = Dict{Tuple{Int, Int}, Matrix{Char}}()
    matched_tile_indices = Dict{Tuple{Int, Int}, String}()
    tile_pair = popfirst!(tile_pairs)
    matched_tiles[(0, 0)] = tile_pair[2]
    matched_tiles_rotated[(0, 0)] = rotateMatrixNegative(tile_pair[2])
    matched_tile_indices[(0, 0)] = tile_pair[1]

    while !isempty(tile_pairs)
        current_tile_pair = popfirst!(tile_pairs)
        current_tile = current_tile_pair[2]
        is_matched = false
        for ((x, y), matched_tile) in matched_tiles
            if matchTiles(matched_tile, current_tile)
                for (n, tile_variation) in enumerate(tileVariations(current_tile))
                    i, j = positionTile(matched_tile, tile_variation)
                    if any((i, j) .!= 0)
                        matched_tiles[(x + i, y + j)] = tile_variation
                        matched_tiles_rotated[(x + i, y + j)] = rotateMatrixNegative(tile_variation)
                        matched_tile_indices[(x + i, y + j)] = current_tile_pair[1]
                        is_matched = true
                        break
                    end
                end
            end
            is_matched && break
        end
        if !is_matched
            push!(tile_pairs, current_tile_pair)
        end
    end

    x_offset = - minimum([i for (i, j) in keys(matched_tiles)]) + 1
    y_offset = - minimum([j for (i, j) in keys(matched_tiles)]) + 1
    picture_dimension = Int(sqrt(number_of_tiles))
    tile_arangement = Matrix{Matrix{Char}}(undef, picture_dimension, picture_dimension)
    indices_arangement = Matrix{String}(undef, picture_dimension, picture_dimension)

    for ((i, j), tile) in matched_tiles_rotated
        tile_arangement[i + x_offset, j + y_offset] = tile
    end
    for ((i, j), ind) in matched_tile_indices
        indices_arangement[i + x_offset, j + y_offset] = ind
    end

    return tile_arangement               
end

function makePicture(tile_arangement::Matrix{Matrix{Char}})
    m, n = size(tile_arangement)
    inner_m, inner_n = size(tile_arangement[1, 1])
    picture = Matrix{Char}(undef, m*(inner_m - 2), n*(inner_n - 2))
    for i in 1:m
        for j in 1:n
            for i_inner in 1:(inner_m - 2)
                for j_inner in 1:(inner_n - 2)
                    tile = tile_arangement[i, j]
                    picture[(i - 1)*(inner_m - 2) + i_inner, (j - 1)*(inner_n - 2) + j_inner] = tile[i_inner + 1, j_inner + 1]
                end
            end
        end
    end

    return picture
end



function getSeaMonster()
    monster_coordinates = Vector{Tuple{Int, Int}}()
    monster_string = "                  # \n#    ##    ##    ###\n #  #  #  #  #  #   "
    for (i, row) in enumerate(split(monster_string, "\n"))
        for (j, character) in enumerate(row)
            if character == '#'
                push!(monster_coordinates, (i, j) .- 1)
            end
        end
    end
    return monster_coordinates
end


function countMonstersOrientation(map::Matrix{Char})
    monster = getSeaMonster()
    monster_length = maximum([i for (i, j) in monster])
    monster_height = maximum([j for (i, j) in monster])

    map_length, map_hight = size(map)
    monster_count = 0

    for i in 1:(map_length - monster_length)
        for j in 1:(map_hight - monster_height)
            monster_count += all([map[k + i, l + j] == '#' for (k, l) in monster])
        end
    end
    return monster_count
end

function countMonsters(map::Matrix{Char})
    return maximum([countMonstersOrientation(map_variation) for map_variation in tileVariations(map)])
end


function computeSeaRoughness(path::String)
    tile_dict = parseInput(path)
    tile_arangement = makeTileArangement(tile_dict)
    picture = makePicture(tile_arangement)

    length_of_monster = 15
    no_monsters = countMonsters(picture)

    return sum(picture .== '#') - length_of_monster*no_monsters
end


# Tests
@test getFinalProduct("../data/day_20_test_1.dat") == 20899048083289
@test computeSeaRoughness("../data/day_20_test_1.dat") == 273


# Results
println("Part 1 solution: ", getFinalProduct("../data/day_20_ch_1.dat"))
println("Part 2 solution: ", computeSeaRoughness("../data/day_20_ch_1.dat"))