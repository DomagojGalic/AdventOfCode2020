using Pkg
#Pkg.activate(".")

using Test
using Match


mutable struct Computer
    cursor::Int64
    accumulator::Int64
    current_command::String
    current_value::Int64
    program::Vector{Tuple{String, Int64}}
    cursor_log::Vector{Int64}
end

function checkInfiniteLoop(computer::Computer)
    return computer.cursor in computer.cursor_log
end

function parseProgram(raw_program::Vector{String})
    clean_program = Vector{Tuple{String, Int64}}()
    for line in raw_program
        command, string_value = split(line)
        value = parse(Int64, string_value)
        push!(clean_program, (command, value))
    end
    return clean_program
end

function Computer(raw_program::Vector{String})
    program = parseProgram(raw_program)
    Computer(1, 0, "", -1, program, Vector{Int64}())
end

function Computer(parsed_program::Vector{Tuple{String, Int64}})
    Computer(1, 0, "", -1, parsed_program, Vector{Int64}())
end

function run(computer::Computer)
    program_length = length(computer.program)
    
    while program_length >= computer.cursor
        cursor = computer.cursor
        computer.cursor += 1
        command, value = computer.program[cursor]
        @match command begin
            "jmp" => begin computer.cursor += (value - 1) end
            "acc" => begin computer.accumulator += value end
            _ => -1
        end
        push!(computer.cursor_log, cursor)

        if checkInfiniteLoop(computer)
            computer.cursor = pop!(computer.cursor_log)
            return false
        end
    end
    return true
end

function swapProgramCommands(original_program::Vector{Tuple{String, Int64}}, breakpoint::Int64)
    program = copy(original_program)

    for (n, (command, value)) in enumerate(program)
        if n <= breakpoint
            continue
        end
        new_breakpoint = n
        if command == "jmp"
            program[n] = ("nop", value)
            return program, new_breakpoint
        elseif command == "nop"
            program[n] = ("jmp", value)
            return program, new_breakpoint
        end
    end
end


function preLoopAccumulator(path::String)
    raw_program = readlines(path)
    computer = Computer(raw_program)

    run(computer)

    return computer.accumulator
end



function rectifyLoopAccumulator(path::String)
    original_program = parseProgram(readlines(path))
    program = deepcopy(original_program)

    breakpoint = 0
    while true
        computer = Computer(program)

        if run(computer)
            return computer.accumulator
        end
        program, new_breakpoint = swapProgramCommands(original_program, breakpoint)
        breakpoint = new_breakpoint
    end
end


# Tests
@test preLoopAccumulator("../data/day_08_test_1.dat") == 5

# Results
println("Part 1 solution: ", preLoopAccumulator("../data/day_08_ch_1.dat"))
println("Part 2 solution: ", rectifyLoopAccumulator("../data/day_08_ch_1.dat"))