#=----------------------------------------------------------
    Compute Monoidal Functors   
----------------------------------------------------------=#

"""
    monoidal_structures(F)

Enumerate monoidal structures up to monoidal natural isomorphism only when
completeness is established. Currently the generic solver supports the
normalised rank-one case. Use `monoidal_structure_candidates` for a possibly
incomplete list of structures in higher rank. Since this branch solves no
equations, it always checks the unique normalized candidate.
"""
function monoidal_structures(F::AbstractFunctor)
    C,D = domain(F),codomain(F)
    is_fusion(C) && is_fusion(D) ||
        throw(ArgumentError("split fusion domain and codomain are required"))
    length(simples(C)) == 1 || throw(ArgumentError(
        "complete monoidal-structure classification is not implemented in this rank; use monoidal_structure_candidates for possibly incomplete candidates"))
    F(one(C)) == one(D) || throw(ArgumentError("the rank-one solver requires a strictly unit-preserving functor"))
    G = monoidal_functor(F,simples(C),Dict((1,1) => id(F(one(C)))))
    # This branch solves no equations, so coherence is an algorithmic decision
    # rather than an optional certificate.
    monoidal_functor_axiom(G) ||
        throw(ArgumentError("the normalised tensorator is not coherent"))
    [G]
end

"""
    monoidal_structure_candidates(F; check=false)

Search for monoidal structures on a strictly unit-preserving
linear functor between split fusion categories. This search is NOT a complete
classification: it fixes selected tensorators/determinants and may sample a
positive-dimensional solution scheme. Failure to find a candidate is not a
proof of nonexistence. EGNO §2.6 classifies pointed examples by H²; the order
of the universal grading group is not the number of structures. The solved
equations already impose coherence; `check=true` re-evaluates it on each output.
"""
function monoidal_structure_candidates(F::AbstractFunctor; check::Bool=false)
    C = domain(F)
    D = codomain(F)
    is_fusion(C) && is_fusion(D) ||
        throw(ArgumentError("split fusion domain and codomain are required"))

    S = simples(C)
    n = length(S)

    F(one(C)) == one(D) || throw(ArgumentError("the candidate search requires a strictly unit-preserving functor"))
    if n == 1
        return monoidal_structures(F)
    end

    one_C = one(C)
    one_index = findfirst(==(one_C), S)
    
    #non_trivial_S = [s for s in S if s != one_C]

    bases = Dict()
    var_numbers = Dict()

    for i ∈ 1:n, j ∈ 1:n
        X,Y = S[[i,j]]
        if one_index ∈ [i,j]
            bases[(i,j)] = [id(F(X ⊗ Y))]
            var_numbers[(i,j)] = 0
        elseif is_isomorphic(X⊗Y, one(C))[1]
            bases[(i,j)] = [id(F(X ⊗ Y))]
            var_numbers[(i,j)] = 0
        else
            bases[(i,j)] = basis(Hom(F(X)⊗F(Y), F(X⊗Y)))
            var_numbers[(i,j)] = length(bases[(i,j)])
        end
    end

    K = base_ring(C)
    R,x = polynomial_ring(K, sum(collect(values(var_numbers))))

    # split variables for bases
    y = copy(x)
    vars = Dict((s,t) => var_numbers[(s,t)] > 0 ? [popfirst!(y) for _ ∈ 1:var_numbers[(s,t)]] : [R(1)] for s ∈ 1:n, t ∈ 1:n)

    if isempty(x)
        tensorators = Dict((i,j) => only(bases[(i,j)]) for i in 1:n,j in 1:n)
        G = monoidal_functor(F,S,tensorators)
        return monoidal_functor_axiom(G) ? [G] : MonoidalFunctor[]
    end
    equations = []
    for (i,j,k) ∈ Base.product(1:n,1:n,1:n)
        if one_index ∈ [i,j,k] continue end

        X,Y,Z = S[[i,j,k]]

        eq_basis = basis(Hom((F(X) ⊗ F(Y)) ⊗ F(Z), F(X ⊗ (Y ⊗ Z))))
        eq = [zero(R) for _ ∈ eq_basis]

        # Decompose X⊗Y and Y⊗Z
        _,_,ixy,pxy = direct_sum_decomposition(X ⊗ Y, S)
        _,_,iyz,pyz = direct_sum_decomposition(Y ⊗ Z, S)
        
        # Equations for J_XY,Z ∘ (J_X,Y ⊗ id_Z) = J_X,YZ ∘ (id_X ⊗ J_Y,Z)
        # First iterate over X,Y , then Y,Z
        
        for (a, J_XY) ∈ zip(vars[(i,j)], bases[(i,j)])
            # Iterate over factors of XY and YZ 

            for (ic,p) ∈ zip(ixy,pxy)
                V = findfirst(==(domain(ic)), S)

                for (c,t) ∈ zip(vars[(V,k)], bases[(V,k)])
                    J_XY_Z = (F(ic ⊗ id(Z))) ∘ t ∘ (F(p) ⊗ id(F(Z)))
                    
                    coeffs = express_in_basis(compose(
                        J_XY ⊗ id(F(Z)),
                        J_XY_Z,
                        F(associator(X,Y,Z))),
                        eq_basis)
                    
                    eq = eq .+ ((a*c) .* coeffs)
                end
               
            end
        end

        for (b, J_YZ) ∈ zip(vars[(j,k)], bases[(j,k)])

            for (ic,p) ∈ zip(iyz,pyz)
                V =  findfirst(==(domain(ic)), S)
                for (c,t) ∈ zip(vars[(i,V)], bases[(i,V)])
                    J_X_YZ = F(id(X) ⊗ ic) ∘ t ∘ (id(F(X)) ⊗ F(p))
                    coeffs = express_in_basis(compose(
                        associator(F(X),F(Y),F(Z)),
                        id(F(X)) ⊗ J_YZ,
                        J_X_YZ),
                        eq_basis)

                    eq = eq .- ((b*c) .* coeffs) 
                end
            end

        end
        equations = [equations; eq]
    end

    unique!(equations)
    filter!(!iszero, equations)

    # # Equations for invertibility
    # iso_mats = [sum([v .* matrix(f) for (v,f) ∈ zip(vars[(x,y)], bases[(x,y)])]) for (x,y) ∈ keys(vars) if !isempty(vars[(x,y)])]

    # KR = fraction_field(R)
    # inv_iso_mats = [inv(change_base_ring(KR, m)) for m ∈ iso_mats]

    # Require det ≠ 0
    mats = [sum([a .* matrix(f) for (a,f) ∈ zip(vars[(x,y)], bases[(x,y)])]) for (x,y) ∈ keys(vars) if !isempty(vars[(x,y)])]

    determinants = det.(mats)
    # A zero constant determinant rules out an invertible tensorator. A
    # nonzero constant needs no constraint; nonconstant determinants below
    # are forced to be units.
    any(iszero,determinants) && return MonoidalFunctor[]
    filter!(d -> !is_constant(d),determinants)
    # @show dets = [det(m) for m ∈ mats]
    # n_dets = length(dets)

    # N = length(x)
    # S,y = polynomial_ring(K, [["x$i" for i ∈ 1:N]; ["d$i" for i ∈ 1:n_dets]])
    
    universal_order = order_of_universal_grading_group(codomain(F))
    equations = [equations; [d^universal_order - 1 for d ∈ determinants]]

    I = ideal(equations)

    sols = dim(I) > 0 ? witness_set(I) : real_solutions_over_base_field(I)
   # sols = [s[1:N] for s ∈ sols]
    
    nats = [Dict((x,y) => sum([v(s...) * t for (v,t) ∈ zip(vars[(x,y)], bases[(x,y)])]) for (x,y) ∈ Base.product(1:n,1:n)) for s ∈ sols]

    # Coherence and invertibility are precisely the equations just solved.
    # Naturality on split simples follows by linearity; avoid solving twice.
    mon_structures = [monoidal_functor(F,S,nat) for nat in nats]
    check && filter!(monoidal_functor_axiom,mon_structures)

    if length(mon_structures) == 0 
        return MonoidalFunctor[]
    end

    unique_structures = mon_structures[1:1]

    if F == id(C) 
        unique_structures =[identity_as_monoidal_functor(C)]
    end

    for G ∈ mon_structures 
        if sum(length(monoidal_natural_transformations(r,G)) for r ∈ unique_structures) == 0 
            push!(unique_structures,G)
        end
    end

    unique_structures
end

function identity_as_monoidal_functor(C::Category)
    indecs = indecomposables(C)
    n = length(indecs)
    MonoidalFunctor(id(C), indecs, Dict((i,j) => id(X⊗Y) for (i,X) ∈ zip(1:n,indecs), (j,Y) ∈ zip(1:n, indecs)))
end

function gauge_group(C::Category)
    monoidal_structures(id(C))
end


function monoidal_natural_transformations(F::AbstractMonoidalFunctor, G::AbstractMonoidalFunctor)

    S = indecomposables(F)

    # Natural transformtions between F,G
    Nats = additive_natural_transformations(F, G, S)

    K = base_ring(domain(F))
    n = length(Nats)
    n == 0 && return AdditiveNaturalTransformation[]

    R,x = polynomial_ring(K,n)

    U = one(domain(F))
    F(U) == one(codomain(F)) && G(U) == one(codomain(G)) ||
        throw(ArgumentError("monoidal natural transformations currently require normalised unit maps"))
    unit_basis = basis(Hom(F(U),G(U)))
    unit_coords = express_in_basis(id(F(U)),unit_basis)
    equations = [-R(c) for c in unit_coords]
    for (a,η) in zip(x,Nats)
        equations .+= a .* express_in_basis(η(U),unit_basis)
    end

    for X ∈ S, Y ∈ S
        eq_basis = basis(Hom(F(X)⊗F(Y), G(X ⊗ Y)))
        eqs = [zero(R) for _ ∈ eq_basis]
        isempty(eq_basis) && continue
        for (a,η) ∈ zip(x, Nats), (b,ν) ∈ zip(x, Nats)

            left = monoidal_structure(G,X,Y) ∘ (η(X) ⊗ ν(Y))  
   
            coeffs = express_in_basis(left, eq_basis)

            eqs = eqs .+ ((a*b) .* coeffs)
        end

        for (a,η) ∈ zip(x, Nats)
            right = (η(X ⊗ Y)) ∘ monoidal_structure(F,X,Y) 
            coeffs = express_in_basis(right, eq_basis)
            eqs = eqs .- ((a) .* coeffs)
        end

        equations = [equations; eqs]
    end
    
    sols = real_solutions_over_base_field(ideal(equations))
    filter!(s -> !all(iszero.(s)), sols)

    mon_nats = [sum(a .* Nats) for a ∈ sols]

    return [AdditiveNaturalTransformation(F,G,S,s.maps) for s ∈ mon_nats]
end

function monoidal_functor_axiom(F::AbstractMonoidalFunctor)
    C,D = domain(F),codomain(F)
    S = indecomposables(F)
    U = one(C)
    F(U) == one(D) || throw(ArgumentError("the checker currently requires normalised unit maps"))
    for X in S
        # In this representation unit maps are identities (EGNO §2.4).
        monoidal_structure(F,U,X) == id(F(X)) || return false
        monoidal_structure(F,X,U) == id(F(X)) || return false
    end
    for X in S,Y in S
        J = monoidal_structure(F,X,Y)
        domain(J) == F(X)⊗F(Y) && codomain(J) == F(X⊗Y) || return false
        is_invertible(J) || return false
        # Naturality on generating morphisms; this also works when the
        # listed generators have non-scalar endomorphisms.
        for X2 in S,Y2 in S,f in basis(Hom(X,X2)),g in basis(Hom(Y,Y2))
            F(f⊗g) ∘ J == monoidal_structure(F,X2,Y2) ∘ (F(f)⊗F(g)) || return false
        end
    end
    for X ∈ S, Y ∈ S, Z ∈ S 
        left = compose(
            monoidal_structure(F,X,Y) ⊗ id(F(Z)),
            monoidal_structure(F, X ⊗ Y, Z),
            F(associator(X,Y,Z))
        )

        right = compose(
            associator(F(X),F(Y),F(Z)),
            id(F(X)) ⊗ monoidal_structure(F,Y,Z),
            monoidal_structure(F, X, Y ⊗ Z)
        )

        if right != left 
            return false 
        end
    end

    true
end
