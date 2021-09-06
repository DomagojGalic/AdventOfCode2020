using Test

function parseRecipe(line::String)
    raw_ingredients, raw_allergens = split(line, " (contains ")
    ingredients = string.(split(raw_ingredients))
    allergens = string.(split(raw_allergens[1:(end - 1)], ", "))
    return ingredients, allergens
end


function parseInput(path::String)
    ingredients_dict = Dict{String, Vector{String}}()
    allergens_dict = Dict{String, Vector{String}}()
    for (line_number, line) in enumerate(readlines(path))
        ingredients, allergens = parseRecipe(line)
        ingredients_dict["recipe_$line_number"] = ingredients
        allergens_dict["recipe_$line_number"] = allergens
    end

    return ingredients_dict, allergens_dict
end

function purgeFromDictValues(dict::Dict{T, Vector{T}}, value::T) where T
    new_dict = Dict{T, Vector{T}}()
    for (key, value_list) in dict
        filtered_list = filter(x -> x != value, value_list)
        if !isempty(filtered_list)
            new_dict[key] = filtered_list
        end
    end
    return new_dict
end

function mergeAllDictValues(dict::Dict{T, Vector{T}}) where T
    all_values = Set{T}()
    for value in values(dict)
        union!(all_values, value)
    end
    return collect(all_values)
end

function pairAllergens(ingredients::Dict{String, Vector{String}}, allergens::Dict{String, Vector{String}})
    ingredients_dict = copy(ingredients)
    allergens_dict = copy(allergens)
    pairings = Dict{String, String}()
    all_allergens = mergeAllDictValues(allergens_dict)

    while !isempty(all_allergens)
        current_allergen = popfirst!(all_allergens)
        current_recipes = [recipe for (recipe, allergen_list) in allergens_dict if current_allergen in allergen_list]
        current_ingredients = [ingredients_dict[recipe] for recipe in current_recipes]

        intersected_ingredients = intersect(current_ingredients...)
        if length(intersected_ingredients) != 1
            push!(all_allergens, current_allergen)
            continue
        end

        paired_ingredient = pop!(intersected_ingredients)
        pairings[paired_ingredient] = current_allergen

        ingredients_dict = purgeFromDictValues(ingredients_dict, paired_ingredient)
        allergens_dict = purgeFromDictValues(allergens_dict, current_allergen)
    end

    return pairings
end

function countNonAllergens(path::String)
    ingredients_dict, allergens_dict = parseInput(path)
    paired_allergens_dict = pairAllergens(ingredients_dict, allergens_dict)

    allergen_ingredients = keys(paired_allergens_dict)

    non_allergen_count = 0
    for (_, ingredients_list) in ingredients_dict
        for ingredient in ingredients_list
            non_allergen_count += !(ingredient in allergen_ingredients)
        end
    end

    return non_allergen_count
end

function canonicalAllergensString(path::String)
    ingredients_dict, allergens_dict = parseInput(path)
    paired_allergens_dict = pairAllergens(ingredients_dict, allergens_dict)

    paired_allergens_inverted_dict = Dict([value => key for (key, value) in paired_allergens_dict])
    all_allergens = sort(collect(values(paired_allergens_dict)))

    ordered_ingredients = [paired_allergens_inverted_dict[allergen] for allergen in all_allergens]

    return join(ordered_ingredients, ",")
end


# Tests
@test countNonAllergens("../data/day_21_test_1.dat") == 5
@test canonicalAllergensString("../data/day_21_test_1.dat") == "mxmxvkd,sqjhc,fvjkl"

# Results
println("Part 1 solution: ", countNonAllergens("../data/day_21_ch_1.dat"))
println("Part 2 solution: ", canonicalAllergensString("../data/day_21_ch_1.dat"))