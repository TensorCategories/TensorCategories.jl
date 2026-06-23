# Testing computation for some specific anyonwiki codes
using TensorCategories, Oscar

codes = [

[2, 1, 0, 1, 2, 1, 1],
[3, 1, 2, 1, 2, 0, 1],
[3, 1, 2, 1, 3, 0, 1],
[4, 1, 0, 1, 1, 1, 1],
[4, 1, 0, 1, 3, 0, 1],
[4, 1, 0, 1, 4, 0, 1],
[4, 1, 2, 1, 2, 1, 1],
[4, 1, 2, 1, 3, 0, 1],
[4, 1, 2, 1, 4, 0, 1],
[4, 1, 2, 2, 1, 0, 1],
[4, 1, 2, 2, 2, 0, 1],
[4, 1, 2, 2, 3, 0, 1],
[4, 1, 2, 2, 4, 0, 1],
[5, 1, 0, 1, 3, 1, 1],
[5, 1, 0, 1, 4, 1, 1],
[5, 1, 0, 6, 2, 1, 1]

]

for code in codes
    println(code)

    C = anyonwiki(code[1],code[2],code[3],code[4],code[5],code[6],code[7])
    Z = center(C)

    simples(Z)
    Z2 = split(Z)[1]
    Z3 = six_j_category(Z2) #This involves computation of F-symbols

    randomized_pentagon_axiom(Z2, 3)
    randomized_pentagon_axiom(Z3, 3)
end
