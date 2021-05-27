function find_set!(disjoint_sets, i) # path compression
    if i != disjoint_sets[i]
        disjoint_sets[i] = find_set!(disjoint_sets, disjoint_sets[i])
    end
    return disjoint_sets[i]
end

function add_set!(disjoint_sets, weights_sets, i, j)
    i = find_set!(disjoint_sets, i)
    j = find_set!(disjoint_sets, j)
    if i == j
        return true
    end
    if weights_sets[i] < weights_sets[j]
        disjoint_sets[i] = j
        weights_sets[j] += weights_sets[i]
    else
        disjoint_sets[j] = i
        weights_sets[i] += weights_sets[j]
    end
    return false
end

function unify_boxes(minimisers)
    n = length(minimisers)
    disjoint_sets = collect(1:n)
    weights_sets = ones(Int, n)

    for i in 1:n, j in i+1:n
        if !isempty(minimisers[i] ∩ minimisers[j])
            add_set!(disjoint_sets, weights_sets, i, j)
        end
    end

    for i in 1:n
        find_set!(disjoint_sets, i) # to flat the structure
    end

    sets = unique(disjoint_sets) # all the unique intervals
    components = [findall(==(set), disjoint_sets) for set in sets] # components

    return [reduce(union, @view minimisers[component]) for component in components]
end
