# Learn
@everywhere function learn(L, depth, input, k, number, alpha, epochs, UU)
	similarity = SharedArray{Float64}(input, number)
	@sync @distributed for i in 1:number
		try
			println("Process ", myid(), " is working on number ", i)
			states = generateAllInfoCompleteStates(L)
			initial_states=[]
			target_states=[]
			circuit = real_variational_circuit(L, depth) 
			for j in 1:input
				states, initial_states, target_states = selectStates(L, depth, j, k, circuit, states, initial_states, target_states)
				x0 = parameters(circuit)
				# Train
				x_opt_exact = train_by_flux_exact_n(L, depth, j, i, alpha, epochs, length(x0), circuit, initial_states, target_states)
				# Compute similarity
				sim = computeSimilarity(x_opt_exact, UU, L, depth)
				similarity[j, i] = sim
				set_parameters!(x_opt_exact, circuit)
			end
			println("Process ", myid(), " finished task ", i)
		catch e
			println("Process ", myid(), " encountered an error: ", e)
		end
	end
	for j in 1:input
		saveResults(L, depth, j, number, similarity[j, :])  
	end
end

