# Controlled-Z gate
@everywhere function getCZ(n,c,t) 
	UU = Matrix{Int64}(I,2^n,2^n)
	num = length(c)
	for i in 1:num
		tmp = Matrix{Int64}(I,2^n,2^n)
		for j in 1:2^n
			s = string(j-1,base =2,pad=n)
			if s[c[i]] == '1' && s[t[i]] == '1'
				tmp[j,j] = -1
			end
		end
		UU = tmp * UU
	end
	return UU
end


# Generate random quantum circuit
@everywhere function generateRQC(n,d,Xseq,Yseq,Tseq)
	X = Rx(pi/2) 
	Y = Ry(pi/2)
	H = 1/sqrt(2)*[1 1;1 -1] 
	T = [exp(-pi/8*im) 0;0 exp(pi/8*im)]
	CZ = [1 0; 0 -1]
	Hgates = H
	for i in 2:n
		Hgates = kron(Hgates,H)
	end
	UU = Hgates
	xindex = 1
	yindex = 1
	tindex = 1
	cindex = 1
	# println(UU)
	for i in 1:d
		flag=zeros(n,1)
		for j in 1:n
			if xindex < length(Xseq) + 1 && i == Xseq[xindex][1] && j == Xseq[xindex][2] 
				xindex = xindex + 1
				flag[j] = 1
			elseif yindex < length(Yseq) + 1 && i == Yseq[yindex][1] && j == Yseq[yindex][2] 
				yindex = yindex + 1
				flag[j] = 2
			elseif tindex < length(Tseq) + 1 && i == Tseq[tindex][1] && j == Tseq[tindex][2] 
				tindex = tindex + 1
				flag[j] = 4
			else
				flag[j] = 0
			end
			# println(flag)
 		end
		if flag[1] == 0
			println("Identity wrong")
		elseif flag[1] == 1
			tmp = X
		elseif flag[1] == 2
			tmp = Y
		else 
			tmp = T
		end
		for j in 2:n
			if flag[j] == 1
				tmp = kron(tmp , X)
			elseif flag[j] == 2
				tmp = kron(tmp , Y)
			else
				tmp = kron(tmp , T)
			end
		end
		c=[]
		t=[]
		for j in 1:2:n
			if mod(i,2) == 1 # odd layer
				if j < n
					push!(c,j)
					push!(t,j+1)
				end
			else
				if j < n-1
					push!(c,j+1)
					push!(t,j+2)
				end
			end
		end

		tmp2 = getCZ(n,c,t)
		UU = tmp*tmp2*UU
	end
	UU = Hgates * UU

	return UU
end

# Generate random sequence
@everywhere function generateRandomSeq(n,d)
	Xseq = []
	Yseq = []
	Tseq = []

	for i in 1:d
		for j in 1:n
			if rand()>0.66
				push!(Xseq,(i,j))
			elseif rand()>0.5
				push!(Yseq,(i,j))
			else
				push!(Tseq,(i,j))
			end
		end
	end
	return Xseq,Yseq,Tseq
end







