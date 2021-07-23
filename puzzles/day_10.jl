using Test
using DelimitedFiles

function parseAdapters(path::String)
    adapters = sort(readdlm(path, Int64)[:])
    pushfirst!(adapters, 0)
    largest = maximum(adapters)
    push!(adapters, largest + 3)
    return adapters
end


function getJoltDifferences(path::String)
    adapters = parseAdapters(path)
    adapter_diffs = diff(adapters)

    one_diff = sum(adapter_diffs .== 1)
    three_diff = sum(adapter_diffs .== 3)

    return one_diff * three_diff
end

function isValidMask(i::Int64, n::Int64, adapters::Vector{Int64})::Bool
    mask = (digits(i, base = 2, pad = n) .== 1)
    return sum(diff(adapters[mask]) .> 3) == 0
end

function divideVector(adapters::Vector{Int64})
    adapter_difs = diff(adapters)

    slices = Vector{Tuple{Int64, Int64}}()
    n = length(adapters)

    is_interior = true
    start_index = 1

    for i in 2:(n - 1)
        if is_interior
            if adapter_difs[i] in (1, 2)
                continue
            elseif adapter_difs[i] == 3
                push!(slices, (start_index, i))
                is_interior = false
            end
        else
            if adapter_difs == 3
                continue
            else
                start_index = i
                is_interior = true
            end
        end
    end
    return slices
end


function numberOfCombinations(adapters::Vector{Int64})
    valid_combinations = 0
    n = length(adapters)
    upper = 2^n - 1
    lower = 2^(n - 1) + 1

    for i in lower:2:upper
        valid_combinations += isValidMask(i, n, adapters)
    end

    return valid_combinations
end

function numberOfCombinations(path::String)
    adapters = parseAdapters(path)
    return numberOfCombinations(adapters)
end


function numberOfCombinationsScalable(path::String)
    adapters = parseAdapters(path)


    slices = divideVector(adapters)
    valid_combinations = 1

    for (lower, upper) in slices
        if upper - lower <= 1
            continue
        end
        valid_combinations *= numberOfCombinations(adapters[lower:upper])
    end
    return valid_combinations
end

# Tests
@test getJoltDifferences("../data/day_10_test_1.dat") == 220
@test numberOfCombinations("../data/day_10_test_2.dat") == 8
@test numberOfCombinationsScalable("../data/day_10_test_1.dat") == 19208


# Results
println("Part 1 solution: ", getJoltDifferences("../data/day_10_ch_1.dat"))
println("Part 2 solution: ", numberOfCombinationsScalable("../data/day_10_ch_1.dat"))