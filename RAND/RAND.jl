# Select a set of quantum states randomly
@everywhere function selectStates(L, input, UU)
	states = generateAllPauliStates(L)
    initial_states=[]
    target_states=[]
	indices = randperm(length(states))[1:input]
	selected_states = states[indices]
	for i=1:input
		x = selected_states[i]
		y = UU * x
		push!(initial_states, x)
		push!(target_states, vector_to_statevector(y))
    end
	return initial_states, target_states
end