# EMCM:  Selected the quantum state with the maximum gradient norm
function selectState(states, circuits, k, circuit)
	result = Float64[]
	len = length(states)
	for i in 1:len
		grad = 0
		initial_state = states[i]
		# k models ensemble predictions
		for j in 1:k
			target_state = circuits[j] * initial_state
			loss_exact(m) = begin
				tmp = target_state - m * initial_state
				v = Real(vdot(conj(tmp), tmp))
				return v 
			end
			# Compute gradient norm
			grad = grad + norm(collect_variables(gradient(loss_exact, circuit)))
		end
		push!(result, grad)
	end
	index = argmax(result)
 	return index, states[index]
end

# Select a set of quantum states
@everywhere function selectStates(L, depth, input, k, circuit, states, initial_states, target_states)
	# k models ensemble 
	circuits = []
	for _ in 1:k
		circ = real_variational_circuit(L, depth) 
		push!(circuits, circ)
	end 
	# @threads for j in 1:k
	# 	try
	# 		println("Thread ", threadid(), " is working on circuit ", j, " for input ", input)
	# 		x0 = parameters(circuits[j])
	# 		if length(initial_states)==0
	# 			index = rand(1:length(states))
	# 			selected_states = states[index]
	# 			x = selected_states
	# 			y = UU * x
	# 			deleteat!(states, index)
	# 			push!(initial_states, x)
	# 			push!(target_states, vector_to_statevector(y))
	# 		end
	# 		x_opt_exact = train_by_flux_exact_n(L, depth, input, -input, alpha, epochs, length(x0), circuits[j], initial_states, target_states)
    #         set_parameters!(x_opt_exact, circuits[j])
	# 		println("Thread ", threadid(), "  set parameters for circuit: ", j)
	# 	catch e
	# 		println("Thread ", threadid(), " encountered an error: ", e)
	# 	end
	# end
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
	index, tmp1 = selectState(states, circuits, k, circuit)
	tmp2 = UU * tmp1
	deleteat!(states, index)
	push!(initial_states, tmp1)
	push!(target_states, vector_to_statevector(tmp2))
	return states, initial_states, target_states
end









