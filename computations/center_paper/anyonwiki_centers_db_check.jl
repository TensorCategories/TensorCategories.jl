using TensorCategories, Oscar

codes = unique(c -> c[1:5], anyonwiki_keys(5))

for (i,cat) in pairs(codes) 

    println(cat)

    Z = anyonwiki_center(cat...)

    if pentagon_axiom(Z) == false
        error("Pengagon axiom not satisfied!")
    end
    
end