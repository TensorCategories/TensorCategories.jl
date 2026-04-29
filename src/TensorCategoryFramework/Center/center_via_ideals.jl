#-------------------------------------------------------------------------------
#   Compute half-braidings by setting up polynomial equations. Not used in 
#   practice, but may be useful for small examples.  
#-------------------------------------------------------------------------------

"""
    is_central(Z::Object)

Return true if ```Z``` is in the categorical center, i.e. there exists a half-braiding on ```Z```.
"""
function is_central(Z::Object, simples::Vector{<:Object} = simples(parent(Z)))
    if prod([is_isomorphic(Z⊗s,s⊗Z)[1] for s ∈ simples]) == 0
        return false
    end
    return dim(build_center_ideal(Z,simples)) >= 0
end

function build_natural_center_ideal(Z::Object, indecs = indecomposables(parent(Z)))
    @assert is_additive(parent(Z))

    # Compute a basis for the natural transformations
    nat_trans = additive_natural_transformations(Z⊗-, (-)⊗Z, indecs)

    K = base_ring(Z)

    Kx,x = polynomial_ring(K, length(nat_trans))

    eqs = []

    i_O = findfirst(e -> is_isomorphic(e,one(parent(Z)))[1], indecs)
    O = indecs[i_O]
    indecs_without_one = filter(e -> (O != e), indecs)

    for X ∈ indecs_without_one, Y ∈ indecs_without_one
        base_ZXY = basis(Hom((Z⊗X)⊗Y, X⊗(Y⊗Z)))
        
        length(base_ZXY) == 0 && continue

        tops = [compose(
            eᵢ(X)⊗id(Y),
            associator(X,Z,Y),
            id(X) ⊗ eⱼ(Y)
        ) for eᵢ ∈ nat_trans, eⱼ ∈ nat_trans]
        
        coeffs = [express_in_basis(t, base_ZXY) for t ∈ tops]
        ab = [a*b for a in x, b in x]
        e =  [a .* c for ((a), c) ∈ zip(ab, coeffs)]

        e = reduce(.+, e)

        bottoms = [compose(
            associator(Z,X,Y),
            eᵢ(X⊗Y),
            associator(X,Y,Z)
        ) for eᵢ ∈ nat_trans]

        coeffs = [express_in_basis(b, base_ZXY) for b ∈ bottoms]

        e2 = [a .* c for (a,c) ∈ zip(x,coeffs)]

        e2 = reduce(.+, e2)

        eqs = [eqs; e .- e2]
    end

    end_Z = basis(End(Z))
    one_coeffs = [express_in_basis(eᵢ(O), end_Z) for eᵢ ∈ nat_trans]
    id_coeffs = express_in_basis(id(Z), end_Z)

    one_eqs = reduce(.+, [a .* c for (a,c) ∈ zip(x,one_coeffs)]) .- id_coeffs
    ideal(unique([eqs; one_eqs]))
end


function build_center_ideal(Z::Object, simples::Vector = simples(parent(Z)))
    #@assert is_semisimple(parent(Z)) "Not semisimple"

    Homs = [Hom(Z⊗Xi, Xi⊗Z) for Xi ∈ simples]
    n = length(simples)
    ks = [int_dim(Homs[i]) for i ∈ 1:n]

    var_count = sum([int_dim(H) for H ∈ Homs])

    K = base_ring(Z)
    R,x = polynomial_ring(K, var_count, internal_ordering = :lex)

    # For convinience: build arrays with the variables xi
    vars = []
    q = 1
    for i ∈ 1:n
        m = int_dim(Homs[i])
        vars = [vars; [x[q:q+m-1]]]
        q = q + m
    end

    eqs = []

    one_index = findfirst(e -> is_isomorphic(one(parent(Z)), e)[1], simples)

    for k ∈ 1:n, i ∈ 1:n, j ∈ 1:n
        if i == one_index || j == one_index continue end

        base = basis(Hom(Z⊗simples[k], simples[i]⊗(simples[j]⊗Z)))

        for t ∈ basis(Hom(simples[k], simples[i]⊗simples[j]))

            l1 = [zero(R) for i ∈ base]
            l2 = [zero(R) for i ∈ base]

            for ai ∈ 1:int_dim(Homs[k])
                a = basis(Homs[k])[ai]
                l1 = l1 .+ (vars[k][ai] .* K.(express_in_basis(associator(simples[i],simples[j],Z)∘(t⊗id(Z))∘a, base)))
            end
            for bi ∈ 1:int_dim(Homs[j]), ci ∈ 1:int_dim(Homs[i])
                b,c = basis(Homs[j])[bi], basis(Homs[i])[ci]
                l2 = l2 .+ ((vars[j][bi]*vars[i][ci]) .* K.(express_in_basis((id(simples[i])⊗b)∘associator(simples[i],Z,simples[j]) ∘ (c⊗id(simples[j])) ∘ inv_associator(Z,simples[i],simples[j]) ∘ (id(Z) ⊗ t), base)))
            end
            push!(eqs, l1 .-l2)
        end
    end
    ideal_eqs = []
    for p ∈ eqs
        push!(ideal_eqs, p...)
    end

    I = ideal([f for f ∈ unique(ideal_eqs) if f != 0])

    #Require e_Z(1) = id(Z)
    
    one_c = K.(express_in_basis(id(Z), basis(End(Z))))
    push!(ideal_eqs, (vars[one_index] .- one_c)...)

    I = ideal([f for f ∈ unique(ideal_eqs) if f != 0])
end

function braidings_from_ideal(Z::Object, I::Ideal, simples::Vector{<:Object}, C)
    Homs = [Hom(Z⊗Xi, Xi⊗Z) for Xi ∈ simples]
    I = rational_lift(I)
    coeffs = recover_solutions(real_solutions(I),base_ring(Z))
    ks = [int_dim(H) for H ∈ Homs]
    centrals = CenterObject[]

    for c ∈ coeffs
        k = 1
        ex = Morphism[]
        c = [k for k ∈ c]
        for i ∈ 1:length(simples)
            if ks[i] == 0 continue end
   
            e = sum(c[k:k + ks[i] - 1] .* basis(Homs[i]))
            ex = [ex ; e]
            k = k + ks[i]
        end
        centrals = [centrals; CenterObject(C, Z, (ex))]
    end
    return centrals
end

"""
    half_braidings(Z::Object)

Return all objects in the center lying over ```Z```.
"""
function half_braidings(Z::Object; simples = simples(parent(Z)), parent = center(parent(Z)))

    I = build_center_ideal(Z,simples)

    d = dim(I)

    if d < 0 return CenterObject[] end

    if d == 0 return braidings_from_ideal(Z,I,simples, parent) end

    solutions = guess_solutions(Z,I,simples,CenterObject[],gens(base_ring(I)),d, parent)

    if length(solutions) == 0
        return CenterObject[]
    end
    unique_sols = solutions[1:1]

    for s ∈ solutions[2:end]
        if sum([dim(Hom(s,u)) for u ∈ unique_sols]) == 0
            unique_sols = [unique_sols; s]
        end
    end
    return unique_sols
end

function guess_solutions(Z::Object, I::Ideal, simples::Vector{<:Object}, solutions::Vector{CenterObject}, vars, d = dim(I), C = center(parent(Z)))
    for y in vars
        J = I + ideal([y*(y^2-1)])
        d2 = dim(J)
        if d2 == 0
            return [solutions; braidings_from_ideal(Z,J,simples,C)]
        elseif d2 < 0
            return solutions
        else
            vars_new = filter(e -> e != y, vars)
            return [solutions; guess_solutions(Z,J,simples,solutions,vars_new,d2,C)]
        end
    end
end


function center_simples(C::CenterCategory, simples = simples(C.category))
    d = dim(C.category)^2

    simples_indices = []
    c_simples = CenterObject[]
    d_max = Int(QQ(ceil(fpdim(C.category))))
    d_rem = d
    k = length(simples)

    coeffs = [i for i ∈ Base.product([0:d_max for i ∈ 1:k]...)][:][2:end]

    for c ∈ sort(coeffs, by = t -> (sum(t),length(t) - length([i for i ∈ t if i != 0])))
        if sum((c .* dim.(simples)).^2) > d_rem continue end

        if simples_covered(c,simples_indices) continue end

        X = direct_sum([simples[j]^c[j] for j ∈ 1:k])[1]

        ic = is_central(X)

        if ic
            so = half_braidings(X, simples = simples, parent = C)
            c_simples = [c_simples; so]
            d_rem = d_rem - sum([dim(x)^2 for x in so])
            if d_rem == 0 return c_simples end
            push!(simples_indices, c)
        end
    end
    if d_rem > 0
        @warn "Not all halfbraidings found"
    end
    return c_simples
end

# function monoidal_completion(simples::Vector{CenterObject})
#     complete_simples = simples
#     for i ∈ 1:length(simples)
#         for j ∈ i:length(simples)
#             X,Y = simples[[i,j]]
#             complete_simples = [complete_simples; [x for (x,m) ∈ simple_subobjects(X⊗Y)]]
#             @show complete_simples
#             complete_simples = unique_simples(complete_simples)
#         end
#     end
#     if length(complete_simples) > length(simples)
#         return monoidal_completion(complete_simples)
#     end
#     return complete_simples
# end

function simples_covered(c::Tuple, v::Vector)
    for w ∈ v
        if *((w .<= c)...)
            return true
        end
    end
    false
end

function is_independent(c::Vector,v::Vector...)
    if length(v) == 0 return true end
    m = matrix(ZZ, [vi[j] for vi ∈ v, j ∈ 1:length(v[1])])

    try
        x = solve(m,matrix(ZZ,c))
    catch
        return true
    end

    return !(*((x .>=0)...))
end

function find_centrals(simples::Vector{<:Object})
    c_simples = typeof(simples[1])[]
    non_central = typeof(simples[1])[]
    for s ∈ simples
        ic, so = is_central(s)
        if ic
            c_simples = [c_simples; so]
        else
            non_central = [non_central; s]
        end
    end
    return c_simples, non_central
end

function partitions(d::Int64,k::Int64)
    parts = []
    for c ∈ Base.product([0:d for i ∈ 1:k]...)
        if sum([x for x ∈ c]) == d
            parts = [parts; [[x for x ∈ c]]]
        end
    end
    return parts
end