using Test: length
using Test

function parseInstruction(instruction::String)
    head, tail = split(instruction, " contain ")
    head = String(strip(replace(head, "bags" => "")))
    tail_list = split(tail, ",")
    
    clean_tail = Vector{String}()

    for item in tail_list
        clean_item = strip(replace(replace(replace(item, "bags" => ""), "bag" => ""), "." => ""))
        if clean_item == "no other"
            return (head, clean_tail)
        end
        key = strip(clean_item[2:end])
        push!(clean_tail, String(key))
    end

    return (head, clean_tail)
end

function parseInstructionWithValues(instruction::String)
    head, tail = split(instruction, " contain ")
    head = String(strip(replace(head, "bags" => "")))
    tail_list = split(tail, ",")
    
    clean_tail = Vector{Tuple{Int64, String}}()

    for item in tail_list
        clean_item = strip(replace(replace(replace(item, "bags" => ""), "bag" => ""), "." => ""))
        if clean_item == "no other"
            return (head, clean_tail)
        end
        
        value = parse(Int64, clean_item[1])
        key = strip(clean_item[2:end])
        push!(clean_tail, (value, String(key)))
    end

    return (head, clean_tail)
end


function parseInstructionSet(path::String)
    instruction_set = Dict{String, Vector{String}}()
    for instruction in readlines(path)
        head, tail = parseInstruction(instruction)
        push!(instruction_set, head => tail)
    end

    return instruction_set
end

function parseInstructionSetWithValues(path::String)
    instruction_set = Dict{String, Vector{Tuple{Int64, String}}}()
    for instruction in readlines(path)
        head, tail = parseInstructionWithValues(instruction)
        push!(instruction_set, head => tail)
    end

    return instruction_set
end


function containsGoldBag(node::String, instruction_set::Dict{String, Vector{String}})
    queue = Vector{String}([node])

    while length(queue) > 0
        current_node = popfirst!(queue)
        if current_node == "shiny gold"
            return true
        end
        append!(queue, instruction_set[current_node])
    end
    return false
end


function countGoldBags(path::String)
    instruction_set = parseInstructionSet(path)
    return length(filter(x -> containsGoldBag(x, instruction_set), keys(instruction_set))) - 1
end


function containedInGoldBag(path::String)
    instruction_set = parseInstructionSetWithValues(path)
    queue = instruction_set["shiny gold"]

    total_bags = 0
    while length(queue) > 0
        value, bag = popfirst!(queue)

        total_bags += value
        contained_bags = instruction_set[bag]
        for (contained_value, contained_bag) in contained_bags
            push!(queue, (value*contained_value, contained_bag))
        end
    end
    return total_bags
end

# Tests
@test countGoldBags("../data/day_07_test_1.dat") == 4
@test containedInGoldBag("../data/day_07_test_1.dat") == 32
@test containedInGoldBag("../data/day_07_test_2.dat") == 126

# Results
println("Part 1 solution: ", countGoldBags("../data/day_07_ch_1.dat"))
println("Part 2 solution: ", containedInGoldBag("../data/day_07_ch_1.dat"))