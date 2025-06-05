# Seqential setting
@everywhere function real_variational_circuit(L::Int, depth::Int)
	circuit = QCircuit()
    for i in 1:depth
		for j in 1:L
			push!(circuit, RzGate(j, Variable(randn(Float64))))
			push!(circuit, RyGate(j, Variable(randn(Float64))))
			push!(circuit, RzGate(j, Variable(randn(Float64))))
		end		
		for j in 1:(L-1)
			push!(circuit, CNOTGate((j, j+1)))
		end
	end	
	for i in 1:L
		push!(circuit, RzGate(i, Variable(randn(Float64))))
		push!(circuit, RyGate(i, Variable(randn(Float64))))
		push!(circuit, RzGate(i, Variable(randn(Float64))))
	end
	return circuit	
end

@everywhere function block(qc, n, d, thetas)
    for i in 0:(n-1)
        qc.rz(thetas[3 * n * d + i * 3 + 1], i)
        qc.ry(thetas[3 * n * d + i * 3 + 2], i)
        qc.rz(thetas[3 * n * d + i * 3 + 3], i)
    end
    for i in 0:(n-2)
        qc.cx(i, i + 1)
    end
    return qc
end

@everywhere function vqc(qc, n, d, thetas)
    for i in 0:(d-1)
        qc = block(qc, n, i, thetas)
    end
    for i in 0:(n-1)
        qc.rz(thetas[3 * n * d + i * 3 + 1], i)
        qc.ry(thetas[3 * n * d + i * 3 + 2], i)
        qc.rz(thetas[3 * n * d + i * 3 + 3], i)
    end
    return qc
end









