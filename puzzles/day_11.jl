using Test
using LinearAlgebra

function parseChairs(path::String)
    chair_layout = reduce(vcat, [reshape(collect(line), 1, :) for line in readlines(path)])
    return chair_layout
end

function checkNumberOfNeighbours(chair_layout::Matrix{Char}, i::Int64, j::Int64)
    m, n = size(chair_layout)

    horizontal_range = maximum((1, i - 1)):minimum((m, i + 1))
    vertical_range = maximum((1, j - 1)):minimum((n, j + 1))

    return sum(chair_layout[horizontal_range, vertical_range] .== '#')
end

function nextIteration(chair_layout::Matrix{Char})
    m, n = size(chair_layout)
    next_layout = copy(chair_layout)

    for i in 1:m
        for j in 1:n
            current_seat = chair_layout[i, j]
            if current_seat == 'L' && checkNumberOfNeighbours(chair_layout, i, j) == 0
                next_layout[i, j] = '#'
            elseif current_seat == '#' && checkNumberOfNeighbours(chair_layout, i, j) >= 5
                next_layout[i, j] = 'L'
            end
        end
    end

    return next_layout
end

function equilibriumOccupancy(path::String)
    chair_layout = parseChairs(path)

    while true
        new_layout = nextIteration(chair_layout)
        if sum(.!(new_layout .== chair_layout)) == 0
            return sum(chair_layout .== '#')
        end
        chair_layout = new_layout
    end
end

function checkRayVector(ray::Vector{Char})
    first_occupied = findfirst(x -> x == '#', ray)
    if first_occupied === nothing
        return false
    else
        first_empty = findfirst(x -> x == 'L', ray)
        if first_empty === nothing || first_occupied < first_empty
            return true
        end
    end
    return false
end

function getDiagonal(A::Matrix{T}, i::Int64, j::Int64) where T
    d = minimum((i, j))
    return diag(A[((i - d) + 1):i, ((j - d) + 1):j])[1:(end - 1)]
end


function getRays(chair_layout::Matrix{T}, i::Int64, j::Int64) where T
    m, n = size(chair_layout)
    rays = Vector{Vector{T}}()
    #up down
    push!(rays, reverse(chair_layout[1:(i - 1), j]))
    push!(rays, chair_layout[(i + 1):m, j])

    #left right
    push!(rays, reverse(chair_layout[i, 1:(j - 1)]))
    push!(rays, chair_layout[i, (j + 1):n])

    #ul dr diagonals
    push!(rays, reverse(getDiagonal(chair_layout, i, j)))
    push!(rays, reverse(getDiagonal(reverse(reverse(chair_layout, dims = 1), dims = 2), m - i + 1, n - j + 1)))

    #ur dl diagonals
    push!(rays, reverse(getDiagonal(reverse(chair_layout, dims = 1), m - i + 1, j)))
    push!(rays, reverse(getDiagonal(reverse(chair_layout, dims = 2), i, n - j + 1)))

    return rays
end

function checkNumberOfNeighboursRay(chair_layout::Matrix{Char}, i::Int64, j::Int64)
    rays = getRays(chair_layout, i, j)
    neighbours = [checkRayVector(ray) for ray in rays]

    return sum(neighbours)
end

function nextIterationRay(chair_layout::Matrix{Char})
    m, n = size(chair_layout)
    next_layout = copy(chair_layout)

    for i in 1:m
        for j in 1:n
            current_seat = chair_layout[i, j]
            if current_seat == 'L' && checkNumberOfNeighboursRay(chair_layout, i, j) == 0
                next_layout[i, j] = '#'
            elseif current_seat == '#' && checkNumberOfNeighboursRay(chair_layout, i, j) >= 5
                next_layout[i, j] = 'L'
            end
        end
    end

    return next_layout
end

function equilibriumOccupancyRay(path::String)
    chair_layout = parseChairs(path)

    iter_number = 1

    while iter_number <= 100
        new_layout = nextIterationRay(chair_layout)
        if sum(.!(new_layout .== chair_layout)) == 0
            return sum(chair_layout .== '#')
        end
        chair_layout = new_layout
        iter_number += 1
    end
end





# Tests
@test equilibriumOccupancy("../data/day_11_test_1.dat") == 37
@test equilibriumOccupancyRay("../data/day_11_test_1.dat") == 26

# Results  -> second one takes long time
println("Part 1 solution: ", equilibriumOccupancy("../data/day_11_ch_1.dat"))
println("Part 2 solution: ", equilibriumOccupancyRay("../data/day_11_ch_1.dat"))