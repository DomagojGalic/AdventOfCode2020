using Test

function parseInitialCoordinates(path::String; dims::Int)
    lines = readlines(path)
    active_cubes = Set{NTuple{dims, Int}}()
    
    for (m, line) in enumerate(lines)
        for (n, activity) in enumerate(line)
            if activity == '#'
                current_point = dims == 3 ? (n, m, 0) : (n, m, 0, 0)
                push!(active_cubes, current_point)
            end
        end
    end
    return active_cubes
end

function getBoundries(active_cubes::Set{NTuple{3, Int}})
    extremal_values = Matrix{Int}(undef, 3, 2)
    for i in 1:3
        extremal_values[i, :] .= extrema([cube[i] for cube in active_cubes])
    end
    return [(extremal_values[i, 1] - 1):(extremal_values[i, 2] + 1) for i in 1:3]
end

function getBoundries(active_cubes::Set{NTuple{4, Int}})
    extremal_values = Matrix{Int}(undef, 4, 2)
    for i in 1:4
        extremal_values[i, :] .= extrema([cube[i] for cube in active_cubes])
    end
    return [(extremal_values[i, 1] - 1):(extremal_values[i, 2] + 1) for i in 1:4]
end

function getAllNeighbours(point::NTuple{3, Int})
    neighbours = Vector{NTuple{3, Int}}()
    for x in -1:1
        for y in -1:1
            for z in -1:1
                if x == 0 && y == 0 && z == 0
                    continue
                end
                push!(neighbours, point .+ (x, y, z))
            end
        end
    end
    return neighbours
end

function getAllNeighbours(point::NTuple{4, Int})
    neighbours = Vector{NTuple{4, Int}}()
    for x in -1:1
        for y in -1:1
            for z in -1:1
                for w in -1:1
                    if x == 0 && y == 0 && z == 0 && w == 0
                        continue
                    end
                    push!(neighbours, point .+ (x, y, z, w))
                end
            end
        end
    end
    return neighbours
end

function numberActiveNeighbours(current_point, active_cubes)
    neighbours = getAllNeighbours(current_point)
    #println(length(neighbours))
    return sum(map(x -> x in active_cubes, neighbours))
end

function updateActivity(active_cubes::Set{NTuple{3, Int}})
    next_active = Set{NTuple{3, Int}}()

    x_range, y_range, z_range = getBoundries(active_cubes)
    for x in x_range
        for y in y_range
            for z in z_range
                current_point = (x, y, z)
                if current_point in active_cubes
                    if 2 <= numberActiveNeighbours(current_point, active_cubes) <= 3
                        push!(next_active, current_point)
                    end
                elseif numberActiveNeighbours(current_point, active_cubes) == 3
                    push!(next_active, current_point)
                end
            end
        end
    end
    return next_active
end

function updateActivity(active_cubes::Set{NTuple{4, Int}})
    next_active = Set{NTuple{4, Int}}()

    x_range, y_range, z_range, w_range = getBoundries(active_cubes)
    for x in x_range
        for y in y_range
            for z in z_range
                for w in w_range
                    current_point = (x, y, z, w)
                    if current_point in active_cubes
                        if 2 <= numberActiveNeighbours(current_point, active_cubes) <= 3
                            push!(next_active, current_point)
                        end
                    elseif numberActiveNeighbours(current_point, active_cubes) == 3
                        push!(next_active, current_point)
                    end
                end
            end
        end
    end
    return next_active
end


function run(path::String, max_iterations::Int; dims::Int)
    active_cubes = parseInitialCoordinates(path, dims = dims)

    for i in 1:max_iterations
        active_cubes = updateActivity(active_cubes)

    end
    return length(active_cubes)
end


# Tests
@test run("../data/day_17_test_1.dat", 6, dims = 3) == 112
@test run("../data/day_17_test_1.dat", 6, dims = 4) == 848

# Results
println("Part 1 solution: ", run("../data/day_17_ch_1.dat", 6, dims = 3))
println("Part 2 solution: ", run("../data/day_17_ch_1.dat", 6, dims = 4))