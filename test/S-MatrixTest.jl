using TensorCategories, Oscar

# This is an exploratory exact S-matrix calculation, not an active test: it is
# not included by test/runtests.jl and contains no @test assertion.  The
# literature matrices below are therefore currently unused as regression
# oracles; converting them into tests should be a separate reviewed change.
# To speed up computation compute the equivalent centre category category
I = I2subcategory(5)
C = center(I)
simples(C)

#Sort the simples in 𝒵(I₂(5)) to match Lusztigs and Malles
C.simples = C.simples[[2,1,3,4]]

S = normalized_smatrix(C)

# Lusztig's S-matrix is from G. Lusztig, "Exotic Fourier transform",
# Duke Math. J. 73 (1994), no. 1, 227--241, with an appendix by G. Malle,
# pp. 243--248, doi:10.1215/S0012-7094-94-07309-2.

K = base_ring(I)
ξ = gen(K)
λ = -ξ^3 + ξ^2 + 1 #(1 + √5)/2

Lusztigs_S = inv(sqrt(K(5))) * matrix(K,[  λ-1 λ   1    1;
                        λ   λ-1 -1   -1;
                        1   -1  λ    -λ+1;
                        1   -1  -λ+1 λ])

# The comparison matrix is from M. Geck and G. Malle, "Fourier transforms and
# Frobenius eigenvalues for finite Coxeter groups", J. Algebra 260 (2003),
# no. 1, 162--193, doi:10.1016/S0021-8693(02)00631-2.

tuples = [(i,j) for i ∈ 0:5, j ∈ 0:5 if 0 < i < j < i+j < 5 || 0 == i < j < 5/2][[1,2,4,3]]
tuples_2 = [(k,l) for k ∈ 1:2:7, l ∈ 1:2:7 if 0 < k < l < k+l < 10][[3,2,1,4]]

Lusztigs_S_formel = matrix(K, [inv(K(5)) * ((ξ^2)^(-i*l+j*k) + (ξ^2)^(i*l-j*k) - (ξ^2)^(-i*k + j*l) - (ξ^2)^(i*k-j*l)) for (i,j) ∈ tuples, (k,l) ∈ tuples])

Q = matrix(K, [inv(K(5)) * (ξ^(i*l+j*k) + ξ^(-i*l-j*k) - ξ^(i*k + j*l) - ξ^(-i*k-j*l)) for (i,j) ∈ tuples, (k,l) ∈ tuples])

# Geck_Malle_S_5 = matrix(K, [inv(K(5)) * ((ξ^2)^(i*l+j*k) + (ξ^2)^(-i*l-j*k) - (ξ^2)^(i*k + j*l) - (ξ^2)^(-i*k-j*l)) for (i,j) ∈ tuples, (k,l) ∈ tuples])

Geck_Malle = matrix(K, [inv(K(5)) * (ξ^(i*l+j*k) + ξ^(-i*l-j*k) - ξ^(i*k + j*l) - ξ^(-i*k-j*l)) for (i,j) ∈ tuples, (k,l) ∈ tuples_2])

N = Lusztigs_S*sqrt(K(5))
M = Geck_Malle*sqrt(K(5))
