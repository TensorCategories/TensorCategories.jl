# This file contains all the code listings from our paper
# "Computing the center of a fusion category"
# 
# Run with julia paper_code_lists.jl

println("Loading packages")
using TensorCategories, Oscar

println("Section 6: Ising category")

function ising_category(K::Ring, a::RingElem)
    C = six_j_category(K,["1", "𝜒", "X"])
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
    set_associator!(C, 2, 3, 2, 3, matrix(K, 1, 1, [-1]))
    set_associator!(C ,3, 2, 3, 2, matrix(K, 1, 1, [-1]))
    set_associator!(C, 3, 3, 3, 3, inv(a)*matrix(K,[1 1; 1 -1]))
    set_one!(C,[1,0,0])
    set_spherical!(C, [K(1) for s in simples(C)])
    set_name!(C, "Ising fusion category")
    return C
end

K,r2 = quadratic_field(2)
C = ising_category(K,r2)
a,b,c = simples(C)

Z = center(C)
S = simples(Z)

H = End(S[4])
minpoly.(basis(H))

Kx,x = base_ring(C)[:x]
L,i = number_field(x^2+1, "i")
L, = absolute_simple_field(L)
ZL = Z ⊗ L
simples(ZL)

_,f = minpoly.(basis(End(ZL[6])))
M,a = number_field(f,"a")
M, = absolute_simple_field(M)
simples(ZL ⊗ M)
simplify(absolute_simple_field(M)[1])[1]

print_multiplication_table(S, ["X$i" for i in eachindex(S)])
smatrix(Z)

half_braiding(Z[4])
R = endomorphism_ring(Z[4])
basis(R)

# Final extra test:
ZM = ZL ⊗ M
if length(simples(ZM)) != 9
    error("Number of simples of ZM not correct")
end

for i=1:length(simples(ZM))
    if dim(End(ZM[i])) != 1
        error("ZM does not split!")
    end
end


println("Section 7: AnyonWiki")

C = anyonwiki(3,1,0,3,1,1,1);
Z = center(C);
simples(Z);
Z2 = split(Z)[1];
Z3 = six_j_category(Z2);

# Avoid overwrite error
rm("/tmp/TensorCategories-section7-test"; recursive=true, force=true)

save_fusion_category(Z3,"/tmp","TensorCategories-section7-test");
Z4 = load_fusion_category("/tmp/TensorCategories-section7-test");

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
num_F_symbs = numeric_F_symbols(Z, precision = 8)
numeric_R_symbols(Z, precision = 8)

# Avoid overwrite error
rm("/tmp/TensorCategories-section7-test"; recursive=true, force=true)

numeric_symbols_to_csv("/tmp/TensorCategories-section7-test", num_F_symbs);
load_numeric_fusion_category("/tmp/TensorCategories-section7-test")

rm("/tmp/TensorCategories-section7-test"; recursive=true, force=true)

C = anyonwiki(QQBarField(),3,1,0,1,2,1,1)
Z = center(C)
simples(Z)
is_unitary.(half_braiding(Z[9]))
Z2 = six_j_category(Z)
is_unitary(associator(Z2[[9,9,9]]...))

println("Extra")

Z = anyonwiki_center(3,1,0,3,1,1,1)
num_F_symbs = numeric_F_symbols(Z)
rm("/tmp/TensorCategories-section7-test"; recursive=true, force=true)
numeric_symbols_to_csv("/tmp/TensorCategories-section7-test", num_F_symbs)
load_numeric_fusion_category("/tmp/TensorCategories-section7-test")
rm("/tmp/TensorCategories-section7-test"; recursive=true, force=true)

C = anyonwiki(1,1,0,1,1,1,1)
Z = center(C)
simples(Z)

println("Finished")