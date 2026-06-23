# This file contains all the code listings from our paper
# "Computing the center of a fusion category"

println("Loading packages")
using TensorCategories, Oscar

println("Section 6")

K,r2 = quadratic_field(2)
I = ising_category(K,r2)
a,b,c = simples(I)
C = center(I)
simples(C)
H = End(C[4])
minpoly.(basis(H))

Kx,x = base_ring(I)[:x]
L,i = number_field(x^2+1, "i")
C2 = C ⊗ L
simples(C2)
_,f = minpoly.(basis(End(C2[6])))
M,a = number_field(f,"a")
simples(C2 ⊗ M) # Check!
simplify(absolute_simple_field(M)[1])[1]

print_multiplication_table(C)

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

