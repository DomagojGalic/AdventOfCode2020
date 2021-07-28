using Test
using DataStructures

struct RangeList
    ranges::Tuple{UnitRange{Int}, UnitRange{Int}}
end

function RangeList(first_range, second_range)
    RangeList((first_range, second_range))
end


function isInRange(range::RangeList, value::Int)
    return any(in.(value, range.ranges)) 
end


function isVectorInRange(rule_range::RangeList, values::Vector{Int})
    return all((x -> isInRange(rule_range, x)).(values))
end


function splitToRange(range::AbstractString)
    first, second = map(x -> parse(Int, x), split(range, "-"))
    return first:second
end


function parseTickets(path::String)
    rules, your_ticket, other_tickets = split(read(path, String), "\n\n")

    field_names = Vector{String}()
    rules_dict = Dict{String, RangeList}()
    for rule in split(rules, "\n")
        field_name, ranges_raw = strip.(split(rule, ":"))
        push!(field_names, field_name)
        rules_dict[field_name] = RangeList(splitToRange.(strip.(split(ranges_raw, "or")))...)
    end

    your_ticket_parsed = map(x -> parse(Int, x), split(split(your_ticket, "\n")[2], ","))

    lines = split(other_tickets, "\n")[2:end]
    other_tickets_data = reduce(vcat, [reshape(map(x -> parse(Int, x), split(line, ",")), 1, :) for line in lines])

    return rules_dict, your_ticket_parsed, (field_names, other_tickets_data)
end


function getValidPositions(tickets_data::Matrix{Int}, rules::Dict{String, RangeList})
    valid_positions = Matrix{Bool}(undef, size(tickets_data)...)
    valid_positions[:, :] .= false

    for (rule_name, rule_range) in rules
        valid_positions = valid_positions .| ((x -> isInRange(rule_range, x)).(tickets_data))
    end
    return valid_positions
end


function computeErrorRate(path::String)
    rules, ticket, (field_names, tickets_data) = parseTickets(path)
    valid_positions = getValidPositions(tickets_data, rules)
    return sum((tickets_data[:])[.!valid_positions[:]])
end


function siftPossibilities(column_possibilities::Dict{Int, Vector{String}})
    pos_dict = deepcopy(column_possibilities)
    column_dict = Dict{String, Int}()

    while length(pos_dict) > 0
        for (i, name_list) in pos_dict
            if length(name_list) == 1
                name = pop!(name_list)
                column_dict[name] = i
            end
        end

        for (i, name_list) in pos_dict
            for name in keys(column_dict)
                filter!(x -> x != name, name_list)
            end
            if length(name_list) == 0
                pop!(pos_dict, i)
            end
        end
    end
    return column_dict
end


function departureMultiplied(path::String)
    rules, ticket, (field_names, tickets_data) = parseTickets(path)
    valid_positions = getValidPositions(tickets_data, rules)
    valid_rows = (.!(sum(.!valid_positions, dims = 2) .> 0))[:]

    valid_tickets = tickets_data[valid_rows, :]
    _, n_columns = size(valid_tickets)

    column_possibilites = Dict{Int, Vector{String}}()
    for column_index in 1:n_columns
        for (rule_name, rule_range) in rules
            if isVectorInRange(rule_range, valid_tickets[:, column_index])
                if !(column_index in keys(column_possibilites))
                    column_possibilites[column_index] = [rule_name]
                else
                    push!(column_possibilites[column_index], rule_name)
                end
            end
        end
    end

    column_dict = siftPossibilities(column_possibilites)

    columns_of_interes = [name for name in field_names if occursin("departure", name)]
    ticket_values_dict = Dict([name => ticket[column_dict[name]] for name in columns_of_interes])

    return prod(values(ticket_values_dict))
end


# Tests
@test computeErrorRate("../data/day_16_test_1.dat") == 71


# Results
println("Part 1 solution: ", computeErrorRate("../data/day_16_ch_1.dat"))
println("Part 2 solution: ", departureMultiplied("../data/day_16_ch_1.dat"))