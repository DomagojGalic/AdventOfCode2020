using Base: Int64, SimpleLogger, check_channel_state, Char
using Test
using DelimitedFiles

struct SimplePolicy
    letter::Char
    lower::Int64
    upper::Int64
end

struct Policy
    letter::Char
    first::Int64
    second::Int64
end

function parseSimplePolicies(path::String)
    lines = readlines(path)
    simple_policies_passwords = Vector{Tuple{SimplePolicy, String}}()

    for line in lines
        letter_range, letter, password = split(line)
        lower, upper = map(x -> parse(Int64, x), split(letter_range, "-"))
        letter = letter[1]

        push!(simple_policies_passwords, (SimplePolicy(letter, lower, upper), String(password)))
    end
    return simple_policies_passwords
end

function checkPasswordAgainsSimplePolicy(policy::SimplePolicy, password::String)
    occurances = sum(collect(password) .== policy.letter)
    return policy.lower <= occurances <= policy.upper
end


function parsePolicies(path::String)
    lines = readlines(path)
    policies_passwords = Vector{Tuple{Policy, String}}()

    for line in lines
        letter_range, letter, password = split(line)
        first, second = map(x -> parse(Int64, x), split(letter_range, "-"))
        letter = letter[1]

        push!(policies_passwords, (Policy(letter, first, second), String(password)))
    end
    return policies_passwords
end


function checkPasswordAgainsPolicy(policy::Policy, password::String)
    if policy.second > length(password)
        return False
    end

    return xor(password[policy.first] == policy.letter, password[policy.second] == policy.letter)
end


#Test
list_policies_passwords = parseSimplePolicies("../data/day_02_test_1.dat")
@test sum(map(x -> checkPasswordAgainsSimplePolicy(x...), list_policies_passwords)) == 2

list_policies_passwords = parsePolicies("../data/day_02_test_1.dat")
@test sum(map(x -> checkPasswordAgainsPolicy(x...), list_policies_passwords)) == 1


#Results
list_policies_passwords_ch = parseSimplePolicies("../data/day_02_ch_1.dat")
println("Part 1 solution: ", sum(map(x -> checkPasswordAgainsSimplePolicy(x...), list_policies_passwords_ch)))

list_policies_passwords_ch = parsePolicies("../data/day_02_ch_1.dat")
println("Part 1 solution: ", sum(map(x -> checkPasswordAgainsPolicy(x...), list_policies_passwords_ch)))