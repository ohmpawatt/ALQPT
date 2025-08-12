function selectState_pureavg(states, circuits, k)
    result = Float64[]
    len = length(states)

    for i in 1:len
        outs = [circuits[j] * states[i] for j in 1:k]
        total_distance = 0.0
        for j in 1:k
            sum_d = 0.0
            for l in 1:k  
                sum_d += sqrt(2 * (1 - abs(vdot(outs[j], outs[l]))))
            end
            total_distance += sum_d / k
        end
        avg_dist = total_distance / k
        push!(result, avg_dist)   
    end

    index = argmax(result)
    return index, states[index]
end



# Select a set of quantum states
function selectStates(L, depth, input, k, alpha, epochs, UU, states, initial_states, target_states)
	# k members committee
	circuits = []
	for _ in 1:k
		circuit = real_variational_circuit(L, depth) 
		push!(circuits, circuit)
	end 
    for j in 1:k
		x0 = parameters(circuits[j])
		if length(initial_states)==0
			index = rand(1:length(states))
			selected_states = states[index]
			x = selected_states
			y = UU * x
			deleteat!(states, index)
			push!(initial_states, x)
			push!(target_states, vector_to_statevector(y))
		end
		x_opt_exact = train_by_flux_exact_n(L, depth, input, -input, alpha, epochs, length(x0), circuits[j], initial_states, target_states)
        set_parameters!(x_opt_exact, circuits[j])
	end
	index, tmp1 = selectState(states, circuits, k)
	tmp2 = UU * tmp1
	deleteat!(states, index)
	push!(initial_states, tmp1)
	push!(target_states, vector_to_statevector(tmp2))
	return states, initial_states, target_states
end








