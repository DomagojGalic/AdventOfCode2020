using Test

function parseScheduele(path::String)
    lines = readlines(path)
    eta = parse(Int64, lines[1])

    line_ids = [parse(Int64, x) for x in filter(x -> x != "", [strip(id) for id in split(replace(lines[2], "x" => ""), ",")])] #::Vector{Int64}
    return eta, line_ids
end

function parseSchedueleDict(path::String)
    line = readlines(path)[2]
    lines = split(line, ",")
    id_lags = Dict{Int64, Int64}()

    for (lag, id) in enumerate(lines)
        if id == "x"
            continue
        end
        pid = parse(Int64, id)
        id_lags[pid] = mod(pid - (lag - 1), pid) 
    end
    return id_lags
end

function rollETAs(path::String)
    eta, line_ids = parseScheduele(path)

    line_dict = Dict{Int64, Int64}()
    for line_id in line_ids
        eta_roll = line_id
        while eta_roll < eta
            eta_roll += line_id
        end
        line_dict[line_id] = eta_roll
    end
    return eta, line_dict
end

function findSoonest(path::String)
    eta, line_dict = rollETAs(path)

    diff_times = Dict([value - eta => key for (key, value) in line_dict])
    soonest = minimum(keys(diff_times))

    return soonest * diff_times[soonest]
end

function findCascade(path::String)
    id_lags = parseSchedueleDict(path)
    time = 0
    step = 1
    for (id, lag) in id_lags
        while mod(time, id) != lag
            time += step
        end
        # next step has to be multiple of passed ids
        step *= id
    end
    return time
end


# Tests
@test findSoonest("../data/day_13_test_1.dat") == 295
@test findCascade("../data/day_13_test_1.dat") == 1068781

# Results
println("Part 1 solution: ", findSoonest("../data/day_13_ch_1.dat"))
println("Part 2 solution: ", findCascade("../data/day_13_ch_1.dat"))