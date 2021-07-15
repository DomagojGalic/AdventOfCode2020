using Test
using DelimitedFiles

function sumOfTwoEntires(entries::Vector)
    n = length(entries)
    for i in 1:(n - 1)
        for j in (i + 1):n
            if entries[i] + entries[j] == 2020
                return entries[i] * entries[j]
            end
        end
    end
end


function sumOfThreeEntires(entries::Vector)
    n = length(entries)
    for i in 1:(n - 2)
        for j in (i + 1):(n - 1)
            for k in (j + 1):n
                if entries[i] + entries[j] + entries[k] == 2020
                    return entries[i] * entries[j] * entries[k]
                end
            end
        end
    end
end


# Tests
entries_test_1 = readdlm("../data/day_01_test_1.dat", Int64)[:]
@test sumOfTwoEntires(entries_test_1) == 514579

@test sumOfThreeEntires(entries_test_1) == 241861950


# Results
entries_ch_1 = readdlm("../data/day_01_ch_1.dat", Int64)[:]
println("Part 1 solution: ", sumOfTwoEntires(entries_ch_1))

println("Part 2 solution: ", sumOfThreeEntires(entries_ch_1))