# Compute similarity
@everywhere function computeSimilarity(x, UU, L, depth)
	x = 2 * x
	qc = QuantumCircuit(L)
	qc = vqc(qc, L, depth, x)
	M = Operator(qc)
	U1 = M.data
	similarity = 1-norm(UU-U1)/2/norm(UU)
	return similarity
end

# Save target unitray

@everywhere function saveUnitary(UU)
	result = JSON.json(OrderedDict("U"=>UU))
	filename = "Results/RAND/$(L)qubit/L" * string(L) * ".txt"
	if !isfile(filename)
		touch(filename)
	end
	io = open(filename, "w")
	write(io, result)  
	close(io)
end

# Save results
@everywhere function saveResults(L, depth, input, number, similarity)
    index = argmax(similarity)
	max_similarity =  similarity[index]
	println("max similarity", similarity[index])
	index  = argmin(similarity)
	min_similarity =  similarity[index]
	println("min similarity", similarity[index])
	average_similarity =  sum(similarity)/number
	println("average similarity", sum(similarity)/number)
	result = JSON.json(OrderedDict("max_similarity"=>max_similarity, "min_similarity"=>min_similarity, "average_similarity"=>average_similarity))
	filename = "Results/RAND/$(L)qubit/Sim/L" * string(L) * "depth" * string(depth) * "inputs" * string(input) * ".txt"
	if !isfile(filename)
		touch(filename)
	end
	io = open(filename, "w")
	write(io, result)  
	close(io)
end


