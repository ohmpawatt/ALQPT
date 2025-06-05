@everywhere function generate_combinations(n)
	X = Rx(pi/2) 
	Y = Ry(pi/2)
	Z = Rz(pi/2)
	paulis = [X, Y, Z]
    if n == 1
        return [[p] for p in paulis]
    else
        prev_combinations = generate_combinations(n - 1)
        new_combinations = []
        for p in prev_combinations
            for q in paulis
                new_combination = vcat(p, [q])  
                push!(new_combinations, new_combination)
            end
        end
        return new_combinations
    end
end

# Generate quantum states
@everywhere function generateAllPauliStates(n)
    initial_state = qstate(Float64, [0]).data
    combinations = generate_combinations(n)
    all_states = []

    for combination in combinations
        global_state = combination[1] * initial_state
        for i in 2:n
            global_state = kron(global_state, combination[i] * initial_state)
        end
        push!(all_states, vector_to_statevector(global_state))
    end

    return all_states
end
