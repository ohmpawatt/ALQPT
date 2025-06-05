# QBC: Selected the quantum state with the maximum variance
function selectState(states, circuits, k)
	result = Float64[]
	len = length(states)
	for i in 1:len
		outs = []
		# k members committee predictions
		for j in 1:k
			push!(outs, circuits[j]*states[i])
		end
		# Compute mean
		average_state = sum(outs) / k
		tmp = 0
		# Compute vaiance
		for j in 1:k
			tmp = tmp + distance(outs[j], average_state)
		end
		push!(result, tmp)
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








