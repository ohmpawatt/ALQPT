@everywhere function vector_to_statevector(vector::Vector)
    return StateVector(vector)
end

@everywhere function copy(L::Int, depth::Int)
    copy_circuit = real_variational_circuit(L, depth)
	return copy_circuit
end

@everywhere function my_operation(tmp)
    return Real(vdot(conj(tmp), tmp))
end

@everywhere function *(Matrix::Matrix{ComplexF64}, state::StateVector{ComplexF64})
    return Matrix * state.data 
end


# Choose initial parameters
@everywhere function choose_initial_paras(L, f, circuit)
    x0 = randn(L)
    set_parameters!(x0, circuit)
    while f(circuit) > 1.9
		println(f(circuit))
		x0 = randn(L)
		set_parameters!(x0, circuit)
		
    end

	return x0
end

# Train
@everywhere function train_by_flux_exact(L ,depth, input, round, alpha, epochs, x0, initial_states, target_states)
	# Loss function
	loss_exact(m) = begin
		v = 0.
		for i in 1:input
			tmp = target_states[i]- m * initial_states[i]
			v += Real(vdot(conj(tmp), tmp))
		end
		return v / input
	end
    # ADAM optimzer
    opt = ADAM(alpha)
	x0_tmp = copy(x0)
	circuit = copy(L, depth)
	# Set initial parameters
	set_parameters!(x0_tmp, circuit)
    for i in 1:epochs
		# Compute gradient
        grad = collect_variables(gradient(loss_exact, circuit))
		# Update parameters
		Optimise.update!(opt, x0_tmp, grad)
		set_parameters!(x0_tmp, circuit)
		# Compute loss
		ss = loss_exact(circuit)
		println("Round $round-th loss at the $i-th step is $ss.")
		if ss < 1e-6
			println("Loss has reached the threshold at epoch $i. Stopping training.")
			break
		end
	end
	return parameters(circuit)
end

# Train
@everywhere function train_by_flux_exact_n(L, depth, input, round, alpha, epochs, len, c, initial_states, target_states)
	# Loss function
	loss_exact(m) = begin
		v = 0.
		for i in 1:input
			tmp = target_states[i]- m * initial_states[i]
			v += Real(vdot(conj(tmp), tmp))
		end
		return v / input
	end
    println("choose_initial_paras")
	# Choose initial parameters
    x0 = choose_initial_paras(len, loss_exact, c)
    println("Done[choose_initial_paras]")
	# Train
	paras = train_by_flux_exact(L ,depth, input, round, alpha, epochs, x0, initial_states, target_states)
	return paras
end