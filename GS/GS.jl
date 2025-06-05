# GS: Selected the quantum state maximum the labeled quantum states
@everywhere function selectState(states, initial_states)
	if length(initial_states)==0
		index = rand(1:length(states))
	else
		result = Float64[]
		len = length(states)
		for i in 1:len
			dis = Inf
			for state in initial_states
				tmp = states[i]- state
				v = Real(vdot(conj(tmp), tmp))
				if v < dis
					dis = v
				end
			end
			push!(result, dis)
		end
		index = argmax(result)
	end
	return index, states[index]
end


# Select a set of quantum states
@everywhere function selectStates(L, input, UU, states, initial_states, target_states)
	index, tmp1 = selectState(states, initial_states)
	tmp2 = UU * tmp1
	deleteat!(states, index)
	push!(initial_states, tmp1)
	push!(target_states, vector_to_statevector(tmp2))
	return states, initial_states, target_states
end








