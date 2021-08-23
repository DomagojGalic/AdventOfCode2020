using Test

function arrayProduct(x, y)
    return [i * j for i in x for j in y]
end

function translateRule(rule::String, rl_dict::Dict{String, Vector{String}})
    return reduce(arrayProduct, [rl_dict[rule_key] for rule_key in split(rule, " ")])
end

function translateRuleArray(rule_vector::Vector{String}, rl_dict::Dict{String, Vector{String}})
    new_rule = String[]
    for rule in rule_vector
        translated = translateRule(rule, rl_dict)
        append!(new_rule, translated)
    end
    return new_rule
end

function parseInputs(path::String)
    instructions, messages = split(read(path, String), "\n\n")
    rules_dict = Dict{String, String}()
    instructions_dict = Dict{String, Vector{String}}()
    for instruction in split(instructions, "\n")
        key, value = split(instruction, ": ")
        value = replace(value, "\"" => "")
        if all(isletter, value)
            rules_dict[key] = value
        else
            instructions_dict[key] = split(value, " | ")
        end
    end
    return rules_dict, instructions_dict, String.(split(messages, "\n"))
end

function untangleRules(rules_dict::Dict{String, String}, instructions_dict::Dict{String, Vector{String}})
    inst_dict = deepcopy(instructions_dict)
    rl_dict = Dict([key => [value] for (key, value) in rules_dict])

    while !isempty(inst_dict)
        for (inst_key, inst_value_arr) in inst_dict
            if all(i in keys(rl_dict) for i in split(join(inst_value_arr, " ")))
                new_rule = translateRuleArray(inst_value_arr, rl_dict)
                if inst_key in keys(rl_dict)
                   append!(rl_dict[inst_key], new_rule)
                else
                    rl_dict[inst_key] = new_rule
                end
                pop!(inst_dict, inst_key)
            end
        end
    end
    return rl_dict
end

function checkSameElements(elems::Vector{Int})
    unique_elems = unique(elems)
    return length(unique_elems) == 1
end

function checkConsistency(rl_dict::Dict{String, Vector{String}})
    elems_32_lens = length.(rl_dict["31"])
    elems_42_lens = length.(rl_dict["42"])

    return checkSameElements(elems_32_lens) && checkSameElements(elems_42_lens) && popfirst!(elems_32_lens) == popfirst!(elems_42_lens)
end


function messagesMatchingRule(path::String)
    rules_dict, instructions_dict, messages = parseInputs(path)
    rl_dict = untangleRules(rules_dict, instructions_dict)
    rule_set = rl_dict["0"]

    return sum([message in rule_set for message in messages])
end

function checkSignatures(chunk_31::Vector{Bool}, chunk_42::Vector{Bool})
    if chunk_31[1] || !chunk_42[1]
        return false
    end
    if sum(abs.(diff(chunk_31))) == 1 && sum(abs.(diff(chunk_42))) == 1 && sum(chunk_42) > sum(chunk_31)
        return true
    else
        return false
    end
end

function messagesMatchingRuleLoops(path::String)
    rules_dict, instructions_dict, messages = parseInputs(path)
    rl_dict = untangleRules(rules_dict, instructions_dict)

    @assert checkConsistency(rl_dict)

    rule_31 = rl_dict["31"]
    rule_42 = rl_dict["42"]

    chunk_size = length(rule_31[1])

    counter = 0
    for message in messages
        chunk_31 = Bool[]
        chunk_42 = Bool[]
        for message_chunk in join.(Iterators.partition(message, chunk_size), "")
            push!(chunk_31, message_chunk in rule_31)
            push!(chunk_42, message_chunk in rule_42)
        end

        if checkSignatures(chunk_31, chunk_42)
            counter += 1
        end
    end              
    
    return counter
end

#Tests
@test messagesMatchingRule("../data/day_19_test_1.dat") == 2
@test messagesMatchingRule("../data/day_19_test_2.dat") == 3
@test messagesMatchingRuleLoops("../data/day_19_test_2.dat") == 12

#Results
println("Part 1 solution: ", messagesMatchingRule("../data/day_19_ch_1.dat"))
println("Part 2 solution: ", messagesMatchingRuleLoops("../data/day_19_ch_1.dat"))