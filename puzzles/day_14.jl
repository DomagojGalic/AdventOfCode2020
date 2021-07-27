using Test
using DataStructures
using Match

function parseInstructions(path::String)
    instructions = Vector{Tuple{String, String, Int}}()
    for line in readlines(path)
        if line[1:4] == "mask"
            command = "mask"
            value_1 = split(line, " = ")[2]
            value_2 = 0
            push!(instructions, (command, value_1, value_2))
        elseif line[1:4] == "mem["
            command = "mem"
            value_1 = split(line[5:end], "]")[1]
            value_2 = parse(Int, split(line, " = ")[2])
            push!(instructions, (command, value_1, value_2))
        else
            error("parsing error")
        end
    end
    return instructions
end

function resolveMaskAddress(mask, bit_value)
    value = ""
    for (x, y) in zip(mask, bit_value)
        if x == '0'
            current_bit = y
        elseif x == '1'
            current_bit = '1'
        else
            current_bit = 'X'
        end
        value *= current_bit
    end
    return value
end

function compute(instructions::Vector{Tuple{String, String, Int}})
    memory = DefaultDict{Int, Int}(0)
    mask = "X"^36

    for (command, value_1, value_2) in instructions
        if command == "mask"
            mask = value_1
        elseif command == "mem"
            address = parse(Int, value_1)
            value = ""
            for (x, y) in zip(mask, bitstring(value_2)[(end - 35):end])
                value *= (x == 'X' ? y : x)
            end
            memory[address] = parse(Int, value; base = 2)
        else
            error("unknow command")
        end
    end
    return memory
end

function getUnmasked(masked::String)
    n = sum(collect(masked) .== 'X')
    pices = split(masked, "X")
    unmasked = Vector{String}()

    for i in 0:(2^n - 1)
        interpolation_values = collect(bitstring(i)[(end - n + 1):end])
        current_value = pices[1]
        for (pice, interpolation_value) in zip(pices[2:end], interpolation_values)
            current_value *= (interpolation_value * pice)
        end
        push!(unmasked, current_value)
    end
    return unmasked
end


function computeAddressWise(instructions::Vector{Tuple{String, String, Int}})
    memory = DefaultDict{Int, Int}(0)
    mask = "0"^36
    for (command, value_1, value_2) in instructions
        #println("c: ", command, ", v1: ", value_1, ", v2: 0", value_2)
        if command == "mask"
            mask = value_1
        elseif command == "mem"
            value = value_2
            masked_address = resolveMaskAddress(mask, bitstring(parse(Int, value_1))[(end - 35):end])
            unmasked_addresses = getUnmasked(masked_address)

            #println(unmasked_addresses, "\n")
            for address in unmasked_addresses
                int_address = parse(Int, address; base = 2)
                memory[int_address] = value
            end
        end
    end
    return memory
end

function getMemorySum(path::String)
    instructions = parseInstructions(path)
    memory = compute(instructions)

    return sum(values(memory))
end

function getMemoryAddressSum(path::String)
    instructions = parseInstructions(path)
    memory = computeAddressWise(instructions)

    return sum(values(memory))
end


# Tests
@test getMemorySum("../data/day_14_test_1.dat") == 165
@test getMemoryAddressSum("../data/day_14_test_2.dat") == 208


# Results
println("Part 1 solution: ", getMemorySum("../data/day_14_ch_1.dat"))
println("Part 2 solution: ", getMemoryAddressSum("../data/day_14_ch_1.dat"))