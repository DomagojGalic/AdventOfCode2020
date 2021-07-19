using Base: answer_color
using Test

function parseAnswers(path::String)
    file = read(path, String)
    lines = [String(line) for line in split(file, "\n\n")]

    return lines
end

function getUniqueAnswers(path::String)
    lines = [replace(replace(line, "\n" => ""), " " => "") for line in parseAnswers(path)]
    unique_answers = [length(unique(collect(line))) for line in lines]

    return unique_answers
end

function getAllAnswers(path::String)
    answer_groups = [split(answer) for answer in parseAnswers(path)]
    all_answers = [length(reduce(intersect, [Set(collect(answer)) for answer in group])) for group in answer_groups]

    return all_answers
end


# Tests
@test sum(getUniqueAnswers("../data/day_06_test_1.dat")) == 11
@test sum(getAllAnswers("../data/day_06_test_1.dat")) == 6

# Results
println("Part 1 solution: ", sum(getUniqueAnswers("../data/day_06_ch_1.dat")))
println("part 2 solution: ", sum(getAllAnswers("../data/day_06_ch_1.dat")))