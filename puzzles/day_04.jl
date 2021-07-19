using Test: Pass
using Base: valid_import_path, check_channel_state
using Test

function parsePassport(line::String)
    
    entries = split(line)
    passport = Dict{String, String}()

    for (key, value) in [split(entry, ":") for entry in entries]
        passport[key] = value
    end
    return passport
end

function parsePassportsBulk(path::String)
    lines = split(read(path, String), "\n\n")
    bulk_passports = [parsePassport(String(line)) for line in lines]

    return bulk_passports
end

function validatePassport(passport::Dict{String, String})
    mandatory_fields = Set(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid"])
    present_keys = Set(keys(passport))
    difference = symdiff(present_keys, mandatory_fields)

    return difference ⊆ Set(["cid"])
end

function validatePassportsBulk(path::String)
    passport_list = parsePassportsBulk(path)
    validated_passports = [validatePassport(passport) for passport in passport_list]
    return sum(validated_passports)
end

function checkYearValues(date::String, least::Int64, most::Int64)
    if ((length(date) != 4) || (tryparse(Int64, date) === nothing))
        return false
    end
    if !(least <= parse(Int64, date) <= most)
        return false
    end
    return true
end

function validatePassportFields(passport::Dict{String, String})
    #byr
    byr = passport["byr"]
    byr_status = checkYearValues(byr, 1920, 2002)
    if !byr_status
        #println("byr: ", byr)
        return false
    end

    #iyr
    iyr = passport["iyr"]
    iyr_status = checkYearValues(iyr, 2010, 2020)
    if !iyr_status
        #println("iyr: ", iyr)
        return false
    end

    #eyr
    eyr = passport["eyr"]
    eyr_status = checkYearValues(eyr, 2020, 2030)
    if !eyr_status
        #println("eyr: ", eyr)
        return false
    end

    #hgt
    hgt = passport["hgt"]
    if hgt[(end - 1):end] == "cm"
        if (tryparse(Int64, hgt[1:(end - 2)]) === nothing)
            #println("hgt: ", hgt)
            return false
        end
        if !(150 <= parse(Int64, hgt[1:(end - 2)]) <= 193)
            #println("hgt: ", hgt)
            return false
        end
    elseif hgt[(end - 1):end] == "in"
        if tryparse(Int64, hgt[1:(end - 2)]) === nothing
            #println("hgt: ", hgt)
            return false
        end
        if !(59 <= parse(Int64, hgt[1:(end - 2)]) <= 76)
            #println("hgt: ", hgt)
            return false
        end
    else
        #println("hgt: ", hgt)
        return false
    end

    #hcl
    hcl = passport["hcl"]
    if !((hcl[1] == '#') && (length(hcl) == 7))
        #println("hcl: ", hcl)
        return false
    end
    for hcl_code in hcl[2:end]
        if (!(hcl_code in '0':'9') && !(hcl_code in 'a':'f'))
            #println("hcl: ", hcl)
            return false
        end
    end

    #ecl
    ecl = passport["ecl"]
    if !(ecl in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"])
        #println("ecl: ", ecl)
        return false
    end

    #pid
    pid = passport["pid"]
    if ((length(pid) != 9) || (tryparse(Int64, pid) === nothing))
        #println("pid: ", pid)
        return false
    end

    return true
end

function validatePassportAndFields(passport::Dict{String, String})
    return validatePassport(passport) && validatePassportFields(passport)
end


function validatePassportsAndFieldsBulk(path::String)
    passport_list = parsePassportsBulk(path)
    validated_passports = [validatePassportAndFields(passport) for passport in passport_list];
    return sum(validated_passports)
end




# Tests
@test validatePassportsBulk("../data/day_04_test_1.dat") == 2
@test validatePassportsAndFieldsBulk("../data/day_04_test_2.dat") == 0
@test validatePassportsAndFieldsBulk("../data/day_04_test_3.dat") == 4

# Results
println("Part 1 solution: ", validatePassportsBulk("../data/day_04_ch_1.dat"))
println("Part 2 solution: ", validatePassportsAndFieldsBulk("../data/day_04_ch_1.dat"))