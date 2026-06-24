using TensorCategories, Oscar
sampled = anyonwiki_keys(3)
for k in sampled
    @show k

    C = anyonwiki(k...)
    Z = center(C)
    Z2, = split(Z)
    Z3 = skeletonize(Z2)

    randomized_pentagon_axiom(Z2, 3)
    randomized_pentagon_axiom(Z3, 3)
end
