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

@everywhere begin
    H = (1/sqrt(2))*[1  1;
                     1 -1]
    S = [1 0;
         0 im]
    ket0 = ComplexF64[1.0; 0.0]
    ket1 = ComplexF64[0.0; 1.0]
         
    ket_plus = H * ket0
    ket_plus_i = S * ket_plus
    D1 = []
    push!(D1, vector_to_statevector(ket0))
    push!(D1, vector_to_statevector(ket1))
    push!(D1, vector_to_statevector(ket_plus))
    push!(D1, vector_to_statevector(ket_plus_i))
    

    function generateAllInfoCompleteStates(n)
        if n == 1
            return D1
        else
            prev_states = generateAllInfoCompleteStates(n - 1)  
            new_states = []  
            for s1 in D1, s2 in prev_states
                kron_vec = kron(s1.data, s2.data)
                push!(new_states, vector_to_statevector(kron_vec))
            end
            return new_states
        end
    end
end




