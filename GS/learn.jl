@everywhere function learn(L, depth, input, number, alpha, epochs, UU)
	similarity = SharedArray{Float64}(number)
	@sync @distributed for i in 1:number
		try
			println("Process ", myid(), " is working on number ", i)
			states = generateAllPauliStates(L)
			initial_states=[]
			target_states=[]
			# Generate a set of quantum states
			for _ in 1:input
				states, initial_states, target_states = selectStates(L, input, UU, states, initial_states, target_states)
			end
			circuit = real_variational_circuit(L, depth) 
			x0 = parameters(circuit)
			# Train
			x_opt_exact = train_by_flux_exact_n(L, depth, input, i, alpha, epochs, length(x0), circuit, initial_states, target_states)
			# Compute similarity
			sim = computeSimilarity(x_opt_exact, UU, L, depth)
			similarity[i] = sim
			println("Process ", myid(), " finished task ", i)
		catch e
			println("Process ", myid(), " encountered an error: ", e)
		end
	end
	# Save results
	saveResults(L, depth, input, number, similarity)
end

