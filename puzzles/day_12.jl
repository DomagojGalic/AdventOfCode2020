using Test
using Match

mutable struct Boat
    heading::Int64
    position_north::Int64
    position_east::Int64
end

mutable struct Waypoint
    position_north::Int64
    position_east::Int64
end

function parseDirections(path::String)
    directions = Vector{Tuple{Char, Int64}}()

    for line in readlines(path)
        direction = line[1]
        magnitude = parse(Int64, line[2:end])
        push!(directions, (direction, magnitude))
    end
    return directions
end

function move!(boat::Boat, direction::Char, magnitude::Int64)
    if direction == 'F'
        orientation = @match boat.heading begin
            0 => 'N'
            90 => 'E'
            180 => 'S'
            270 => 'W'
        end
    else
        orientation = direction
    end

    @match orientation begin
        'N' => begin boat.position_north += magnitude end
        'S' => begin boat.position_north -= magnitude end
        'E' => begin boat.position_east += magnitude end
        'W' => begin boat.position_east -= magnitude end

        # modulus can return value < 0
        'L' => begin boat.heading = (boat.heading - magnitude + 360) % 360 end
        'R' => begin boat.heading = (boat.heading + magnitude + 360) % 360 end
    end
end

function rotate!(waypoint::Waypoint, magnitude::Int64)
    phi = - (magnitude / 180) * π
    rotation_matrix = Int64.(round.([cos(phi) -sin(phi); sin(phi) cos(phi)]))

    waypoint.position_east, waypoint.position_north = rotation_matrix * [waypoint.position_east, waypoint.position_north]
end

function move!(boat::Boat, waypoint::Waypoint, direction::Char, magnitude::Int64)
    @match direction begin
        'N' => begin waypoint.position_north += magnitude end
        'S' => begin waypoint.position_north -= magnitude end
        'E' => begin waypoint.position_east += magnitude end
        'W' => begin waypoint.position_east -= magnitude end

        'L' => begin rotate!(waypoint, -magnitude) end
        'R' => begin rotate!(waypoint, magnitude) end

        'F' => begin
            boat.position_north += magnitude * waypoint.position_north
            boat.position_east += magnitude * waypoint.position_east
        end
    end
end

function boatPosition(path::String)
    directions = parseDirections(path)
    boat = Boat(90, 0, 0)

    for (direction, magnitude) in directions
        move!(boat, direction, magnitude)
    end

    return abs(boat.position_north) + abs(boat.position_east)
end

function boatPositionWaypoint(path::String)
    directions = parseDirections(path)
    boat = Boat(0, 0, 0)
    waypoint = Waypoint(1, 10)

    for (direction, magnitude) in directions
        move!(boat, waypoint, direction, magnitude)
        #println("direction: ", direction, ", magnitude: ", magnitude)
        #println("boat: ", boat)
        #println("waypoint: ", waypoint, "\n")
    end

    return abs(boat.position_north) + abs(boat.position_east)
end


# Tests
@test boatPosition("../data/day_12_test_1.dat") == 25
@test boatPositionWaypoint("../data/day_12_test_1.dat") == 286


# Results
println("Part 1 solution: ", boatPosition("../data/day_12_ch_1.dat"))
println("Part 2 solution: ", boatPositionWaypoint("../data/day_12_ch_1.dat"))