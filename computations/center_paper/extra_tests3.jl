using TensorCategories, Oscar, ProgressMeter

allcodes = anyonwiki_keys(5)

nonequivkeys = unique(k -> k[1:5], allcodes)

nonequivcats = []

@showprogress desc="Loading cats" for k in nonequivkeys
    push!(nonequivcats, anyonwiki(k...))
end

function check_pentagon_equations(cat,perm;inv = false)
    fsymb =
        if inv
            Dict(k[perm] => v for (k,v) in inverse_F_symbols(cat)) #We don't need this anymore
        else
            Dict(k[perm] => v for (k,v) in F_symbols(cat; convention=:bonderson)) #New convention keyword
        end

    r = rank(cat)
    mt = multiplication_table(cat)
    n_checked = 0
    K = base_ring(cat)

    getF(v) = haskey(fsymb,v) ? fsymb[v] : throw("KeyNotFound")

    @inbounds for a in 1:r, b in 1:r, c in 1:r, d in 1:r
        for f in 1:r
            mt[a, b, f] == 0 && continue # a×b -> f
            for l in 1:r
                mt[c, d, l] == 0 && continue # c×d -> l
                for g in 1:r
                    mt[f, c, g] == 0 && continue # f×c -> g (g = total of a,b,c)
                    for k in 1:r
                        mt[b, l, k] == 0 && continue # b×l -> k (k = total of b,c,d)
                        for e in 1:r
                            mt[g, d, e] * mt[f, l, e] * mt[a, k, e] == 0 && continue
                            # note: we don’t check equations where LHS = 0 yet.
                            lhs =
                                try
                                    getF([f, c, d, e, g, l]) * getF([a, b, l, e, f, k])
                                catch error
                                    return false, (a,b,c,d,e,f,g,k,l,"lhs","KeyNotFound")
                                end
                            rhs = K(0)
                            try
                                for h in 1:r
                                    mt[b, c, h] == 0 && continue # b×c -> h
                                    mt[a, h, g] == 0 && continue # a×h -> g
                                    mt[h, d, k] == 0 && continue # h×d -> k
                                    rhs += getF([a, b, c, g, f, h]) *
                                        getF([a, h, d, e, g, k]) *
                                        getF([b, c, d, k, h, l])
                                end
                            catch error
                                return false, (a,b,c,d,e,f,g,k,l,"rhs","KeyNotFound")
                            end
                            if lhs - rhs != 0
                                return false, (a,b,c,d,e,f,g,k,l,lhs,rhs)
                            end
                        end
                    end
                end
            end
        end
    end
    return true, (0,0,0,0,0,0,0,0,0,0,0,0)
end

S_6 = symmetric_group(6)

# No permutations needed anymore, perm=id works
#@showprogress for el in S_6
el = one(S_6)

println("=== Checking pentagon eqns for label permutation ", el)
for cat in nonequivcats[2:end] #don’t need to check trivial cat
    println("> ",cat.name)
    check = check_pentagon_equations(cat,Vector(el),inv=false)
    !(typeof(check)<:Tuple) && throw(cat.name)
    if first(check) == false
        println(cat.name, " : false eqn: ", check[2])
        println("")
        break
    end
end

#end
