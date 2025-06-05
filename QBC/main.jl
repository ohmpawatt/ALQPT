using Distributed
using Base.Threads

# addprocs(16)

@everywhere using SharedArrays
@everywhere using VQC
@everywhere using VQC: ZERO
@everywhere using KrylovKit: eigsolve
@everywhere using LinearAlgebra
@everywhere using Zygote
@everywhere using Zygote: @adjoint
@everywhere using Optim
@everywhere using JSON
@everywhere using Flux
@everywhere using Flux.Optimise
@everywhere using Random
@everywhere using OrderedCollections
@everywhere import Base:copy
@everywhere import Base:*
@everywhere using PyCall
@everywhere qiskit = pyimport("qiskit")
@everywhere QuantumCircuit = qiskit.QuantumCircuit
@everywhere Operator = qiskit.quantum_info.Operator
@everywhere using Plots

include("../Model/states.jl")
include("../Model/VQC.jl")
include("../Model/RQC.jl")
include("../Model/train.jl")
include("QBC.jl")
include("learn.jl")
include("save.jl")


# Example: 4-qubit, 7-depth

alpha = 0.1 # Learning rate
epochs = 50 # Iteration steps
number = 100 # Repeate numbers
L = 4 # Numbers of qubits
input = 4 # Number of quantum states
D = 6 # RQC depth
depth = 1 # VQC depth
k = 7 # Number of committee members

# Generate target unitray
Xseq,Yseq,Tseq = generateRandomSeq(L,D)
UU = generateRQC(L,D,Xseq,Yseq,Tseq)
saveUnitary(UU)

# Learn 
learn(L, depth, input, k, number, alpha, epochs, UU)




