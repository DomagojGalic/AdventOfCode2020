using Test

function noParentheses(string_exp::String)
    arr_exp = split(string_exp)
    subtotal = parse(Int, popfirst!(arr_exp))

    while !isempty(arr_exp)
        operator = popfirst!(arr_exp)
        operand = parse(Int, popfirst!(arr_exp))
        if operator == "+"
            subtotal += operand
        elseif operator == "*"
            subtotal *= operand
        else
            return ErrorException("unknown operator $(operator)")
        end
    end
    return subtotal
end

function noParenthesesPrecedence(string_exp::String)

    arr_exp = split(string_exp)
    n = length(string_exp)

    while true
        plus_index = findfirst(x -> x == "+", arr_exp)
        if plus_index === nothing
            break
        end
        if plus_index == 2
            prefix = String[]
        else
            prefix = arr_exp[1:(plus_index - 2)]
        end

        if plus_index == n - 1
            suffix = String[]
        else
            suffix = arr_exp[(plus_index + 2):end]
        end

        middle = parse(Int, arr_exp[plus_index - 1]) + parse(Int, arr_exp[plus_index + 1])
        arr_exp = [prefix; "$middle"; suffix]
    end

    return eval(Meta.parse(join(arr_exp, " ")))
end

function extractInnermostIndices(string_exp::String)
    current_level = 0
    max_level = 0
    max_position = 1
    for (n, character) in enumerate(string_exp)
        if character == '('
            current_level += 1
            max_position = current_level > max_level ? n : max_position
            max_level = current_level > max_level ? current_level : max_level
        elseif character == ')'
            current_level -= 1
        end
    end

    if max_level == 0
        last_position = length(string_exp) - 1
    else
        last_position = findfirst(x -> x == ')', string_exp[max_position:end])
    end

    return max_position, max_position + last_position - 1, max_level
end


function computeWithParenthases(string_exp::String)

    current_exp = string_exp

    while true
        first_position, last_position, max_level = extractInnermostIndices(current_exp)

        if max_level == 0
            return noParentheses(current_exp)
        end

        middle = noParentheses(current_exp[(first_position + 1):(last_position - 1)])
        prefix = current_exp[1:(first_position - 1)]
        suffix = current_exp[(last_position + 1):end]

        current_exp = prefix * "$middle" * suffix
        
    end
end

function computeWithParenthasesPrecedence(string_exp::String)

    current_exp = string_exp

    while true
        first_position, last_position, max_level = extractInnermostIndices(current_exp)

        if max_level == 0
            return noParenthesesPrecedence(current_exp)
        end

        middle = noParenthesesPrecedence(current_exp[(first_position + 1):(last_position - 1)])
        prefix = current_exp[1:(first_position - 1)]
        suffix = current_exp[(last_position + 1):end]

        current_exp = prefix * "$middle" * suffix
        
    end
end

function sumMultiple(path::String)
    lines = readlines(path)
    return sum(computeWithParenthases.(lines))
end

function sumMultiplePrecedence(path::String)
    lines = readlines(path)
    return sum(computeWithParenthasesPrecedence.(lines))
end


# Tests
@test computeWithParenthases("1 + 2 * 3 + 4 * 5 + 6") == 71
@test computeWithParenthases("1 + (2 * 3) + (4 * (5 + 6))") == 51
@test computeWithParenthases("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 13632
@test computeWithParenthasesPrecedence("1 + 2 * 3 + 4 * 5 + 6") == 231
@test computeWithParenthasesPrecedence("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 23340


# Results
println("Part 1 solution: ", sumMultiple("../data/day_18_ch_1.dat"))
println("Part 2 solution: ", sumMultiplePrecedence("../data/day_18_ch_1.dat"))