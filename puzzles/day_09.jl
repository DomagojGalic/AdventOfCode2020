using Test
using DelimitedFiles

function parseCode(path::String)
    code = readdlm(path, Int64)[:]
    return code
end

function generateCombinations(preamble::Vector{Int64})
    n = length(preamble)
    combinations = Vector{Int64}()
    for i in 1:(n - 1)
        for j in (i + 1):n
            push!(combinations, preamble[i] + preamble[j])
        end
    end
    return combinations
end

function findFirstViolation(path::String, preamble_length::Int64 = 5)
    code = parseCode(path)
    n = length(code)

    for i in (preamble_length + 1):n
        preamble = code[(i - preamble_length):(i - 1)]
        combinations = generateCombinations(preamble)

        if !(code[i] in combinations)
            return i, code[i]
        end
    end
end

function findCorrectSlider(path::String, preamble_length::Int64 = 5)
    code = parseCode(path)
    n = length(code)
    _, target_value = findFirstViolation(path, preamble_length)

    for slider_length in 2:n
        for i in 1:(n - slider_length + 1)
            slider_window = code[i:(i + slider_length - 1)]
            if sum(slider_window) == target_value
                return sum(extrema(slider_window))
            end
        end
    end
    return "Drek"
end




# Test
@test findFirstViolation("../data/day_09_test_1.dat")[2] == 127
@test findCorrectSlider("../data/day_09_test_1.dat") == 62


# Results
println("Part 1 solution: ", findFirstViolation("../data/day_09_ch_1.dat", 25)[2])
println("Part 2 solution: ", findCorrectSlider("../data/day_09_ch_1.dat", 25))