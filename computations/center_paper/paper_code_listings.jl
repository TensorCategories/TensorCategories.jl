# This file contains all the code listings from our paper
# "Computing the center of a fusion category"

println("Loading packages")
using TensorCategories, Oscar

println("Section 6")

function ising_cat(F::Ring, a::RingElem)
    C = six_j_category(F,["1", "𝜒", "X"])
    # Multiplication table of the Grothendieck ring
    M = zeros(Int,3,3,3)
    M[1,1,:] = [1,0,0]
    M[1,2,:] = [0,1,0]
    M[1,3,:] = [0,0,1]
    M[2,1,:] = [0,1,0]
    M[2,2,:] = [1,0,0]
    M[2,3,:] = [0,0,1]
    M[3,1,:] = [0,0,1]
    M[3,2,:] = [0,0,1]
    M[3,3,:] = [1,1,0]
    set_tensor_product!(C,M)
    # The associators
    set_associator!(C,2,3,2, matrices(-id(C[3])))
    set_associator!(C,3,2,3, matrices((id(C[1]))⊕(-id(C[2]))))
    z = zero(matrix_space(F,0,0))
    set_associator!(C,3,3,3, [z, z, inv(a)*matrix(F,[1 1; 1 -1])])
    set_one!(C,[1,0,0])
    set_spherical!(C, [F(1) for s in simples(C)])
    set_name!(C, "Ising fusion category")
    return C
end

K,r2 = quadratic_field(2)
I = ising_cat(K,r2)
a,b,c = simples(I)
C = center(I)
simples(C)
H = End(C[4])
minpoly.(basis(H))

Kx,x = base_ring(I)[:x]
L,i = number_field(x^2+1, "i")
L, = absolute_simple_field(L)
C2 = C ⊗ L
simples(C2)
_,f = minpoly.(basis(End(C2[6])))
M,a = number_field(f,"a")
M, = absolute_simple_field(M)
simples(C2 ⊗ M) 
simplify(absolute_simple_field(M)[1])[1]

print_multiplication_table(C)
smatrix(C)

half_braiding(C[4])
R = endomorphism_ring(C[4])
basis(R)

println("Section 7")

C = anyonwiki(4,1,2,4,1,0,1)
Z = anyonwiki_center(4,1,2,4,1,0,1)
simples(C)
print_multiplication_table(C)
simples(Z)
print_multiplication_table(multiplication_table(Z))
view(smatrix(Z),1:4,1:4)
diagonal(tmatrix(Z))
F_symbols(Z)
R_symbols(Z)
numeric_F_symbols(Z, precision = 8) 
numeric_R_symbols(Z, precision = 8)

