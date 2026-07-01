using TensorCategories, Oscar, BenchmarkTools

C = anyonwiki(4, 1, 0, 5, 3, 1, 1)
Z = center(C)

print("simples(Z): ")
S = @btime simples($Z)

print("split(Z)[1]: ")
Z2 = @btime split($Z)[1]

print("six_j_category(Z2): ")
Z3 = @btime six_j_category($Z2)