
function _require_split_semisimple_coordinates(C::Category, operation::String,
                                                S=nothing)
    is_multiring(C) || throw(ArgumentError(
        "$operation requires a semisimple monoidal category"))
    if S === nothing
        is_split_semisimple(C) || throw(ArgumentError(
            "$operation requires split simple endomorphism rings"))
    else
        is_semisimple(C) || throw(ArgumentError(
            "$operation requires a semisimple source category"))
        all(X -> parent(X) === C, S) || throw(ArgumentError(
            "the supplied simple objects must belong to the source category"))
        all(X -> int_dim(End(X)) == 1, S) || throw(ArgumentError(
            "$operation requires split simple endomorphism rings"))
    end
end

function _check_skeletal_structure(C::SixJCategory, spherical::Bool)
    pentagon_axiom(C) || throw(ArgumentError(
        "the transported associator does not satisfy the pentagon equation"))
    if is_braided(C)
        hexagon_axiom(C) || throw(ArgumentError(
            "the transported braiding does not satisfy the hexagon equations"))
    end
    is_pivotal(C;check=true) || throw(ArgumentError(
        "the transported pivotal structure is not monoidal"))
    if spherical
        is_spherical(C;check=true) || throw(ArgumentError(
            "the transported pivotal structure is not spherical"))
    end
    C
end

function _require_resolved_nonzero_dimension(d, i::Int, source::String)
    if !Oscar.is_exact_type(typeof(d)) && applicable(Oscar.contains_zero,d)
        Oscar.contains_zero(d) && throw(ArgumentError(
            "$source dimension of simple $i contains zero at the working precision; " *
            "increase the precision before skeletonization"))
    elseif iszero(d)
        throw(ArgumentError(
            "$source dimension of simple $i is zero; this contradicts the " *
            "split semisimple pivotal hypotheses of skeletonization"))
    end
    d
end

function _skeletal_pivotal_coefficients(C::Category, S::Vector{<:Object},
                                         skel_C::SixJCategory)
    source_dims = try
        dim.(S)
    catch e
        e isa InterruptException && rethrow()
        throw(ArgumentError(
            "skeletonization could not evaluate the source pivotal structure: " *
            sprint(showerror,e)))
    end
    skeletal_dims = dim.(simples(skel_C))
    for i in eachindex(S)
        _require_resolved_nonzero_dimension(source_dims[i],i,"source pivotal")
        _require_resolved_nonzero_dimension(skeletal_dims[i],i,"reference skeletal")
    end
    source_dims ./ skeletal_dims
end

function skeletonize(C::Category, names::Vector{String} = simples_names(C);
                     check::Bool=false)
    six_j_category(C, names;check)
end

function six_j_category(C::Category, names::Vector{String} = simples_names(C);
                        check::Bool=false)
    F = six_j_category(C, simples(C), names;check)
    set_name!(F, "Skeletonization of $C")
    return F
end

function six_j_category(C::Category, S::Vector{<:Object},
                        names::Vector{String} = simples_names(parent(S[1]));
                        check::Bool=false)
    if C isa SixJCategory
        check && _check_skeletal_structure(C,is_spherical(C))
        return C
    end
    is_ring(C) || throw(ArgumentError(
        "skeletonization as a SixJ category requires a simple unit"))
    _require_split_semisimple_coordinates(C,"skeletonization",S)
    
    #S = simples(C)
    n = length(S)
    F = base_ring(C)
    source_is_spherical = try
        is_spherical(C)
    catch e
        e isa InterruptException && rethrow()
        false
    end


    # prods = [X ⊗ Y for X ∈ S, Y ∈ S]
    # homs = [basis(Hom(prods[i,j],Z)) for i ∈ 1:length(S), j ∈ 1:length(S), Z ∈ S]
    # for i ∈ 1:n, j ∈ 1:n
    #     mult[i,j,:] = [length(homs[i,j,k]) for k ∈ 1:n]
    # end

    # Define SixJCategory
    skel_C = six_j_category(F,names)

    # Choose one system of multiplicity-space bases for the associator and
    # braiding. Recomputing a Hom basis between the two changes their common
    # gauge and can destroy the hexagon equations.
    S = copy(S)
    one_indices = findall(s -> int_dim(Hom(s,one(C))) > 0,S)
    S[one_indices] = simple_subobjects(one(C))
    homs = multiplicity_spaces(C,S)
    ass = six_j_symbols(C,S;homs)

    # Recover multiplication table 
    one_index = findfirst(s -> int_dim(Hom(one(C),s)) > 0, S)
    set_one!(skel_C, [i == one_index for i ∈ 1:n])

    mult = [size(ass[i,j,one_index,k], 1) for i ∈ 1:n, j ∈ 1:n, k ∈ 1:n]

    set_tensor_product!(skel_C, mult)

    set_associator!(skel_C, ass)

    # The trace of an isomorphism from a split simple to its double dual is
    # nonzero in a semisimple tensor category (EGNO, Proposition 4.8.4).
    # Hence traces give faithful coordinates on these one-dimensional Hom
    # spaces, including in positive characteristic.  The reference traces
    # below use the skeletal duality determined by the same `homs` bases as
    # the F- and R-symbols.
    sp = _skeletal_pivotal_coefficients(C,S,skel_C)
    if source_is_spherical
        set_spherical!(skel_C,sp)
    else
        set_pivotal!(skel_C,sp)
    end

    if is_braided(C)
        set_braiding!(skel_C,skeletal_braiding(C,S;homs))
    end
    
    try 
        skel_C.embedding = complex_embedding_of_base_ring(C)
    catch
    end

    check && _check_skeletal_structure(skel_C,source_is_spherical)

    return skel_C
end

function _fusion_subcategory_product_matrices(products, number_of_generators::Int,
                                               number_of_simples::Int)
    products === nothing && return nothing
    raw = products isa AbstractMatrix ? Any[products] : collect(products)
    length(raw) == number_of_generators || throw(ArgumentError(
        "products must contain one matrix for each generator"))
    matrices = Matrix{Int}[]
    for A in raw
        size(A) == (number_of_simples, number_of_simples) || throw(ArgumentError(
            "each product matrix must have one row and column for every supplied simple"))
        M = zeros(Int,number_of_simples,number_of_simples)
        for i in 1:number_of_simples, j in 1:number_of_simples
            m = try
                Int(A[i,j])
            catch
                throw(ArgumentError("product multiplicities must be integers"))
            end
            m >= 0 && A[i,j] == m || throw(ArgumentError(
                "product multiplicities must be nonnegative integers"))
            M[i,j] = m
        end
        push!(matrices,M)
    end
    matrices
end

@doc raw"""
    fusion_subcategory(generators::Vector{<:Object}; simples, products=nothing,
                       names=["X1", ...], skeletal=false, check=true, rng=nothing)
    fusion_subcategory(generator::Object; kwargs...)

Construct the fusion subcategory generated by the supplied split simple
objects `generators` inside a semisimple tensor category. The keyword `simples`
gives the proposed complete list of simple objects of that subcategory.

If `products` is supplied, it is one nonnegative integer matrix for every
generator. Entry `(k,j)` is the proposed multiplicity of `simples[k]` in
`generators[a] ⊗ simples[j]`. For one generator, a single matrix may be passed
directly. Otherwise these multiplicities are computed from Hom spaces.

With `check=true`, the function verifies that the proposed objects are
pairwise distinct split simples, contain the tensor unit and the generators,
are closed under duality, and are all reached from the unit by the generator
products. Every proposed generator product is checked by constructing an
explicit direct-sum isomorphism with [`decomposition_isomorphism`](@ref).
The current isomorphism search requires a finite coefficient field.
With `check=false`, these potentially expensive Hom-space and decomposition
checks are omitted; the tensor unit and generators must then occur literally
in `simples`.

The result is a concrete `FusionSubcategory` whose operations are inherited
from the ambient category. Set `skeletal=true` to transport its associator,
braiding when present, and pivotal structure to a `SixJCategory`. In either
case, the simple ordering is the ordering of `simples`.
"""
function fusion_subcategory(generators::Vector{<:Object};
                            simples::Vector{<:Object}, products=nothing,
                            names::Vector{String}=["X$i" for i in eachindex(simples)],
                            skeletal::Bool=false, check::Bool=true, rng=nothing)
    isempty(generators) && throw(ArgumentError("at least one generator is required"))
    isempty(simples) && throw(ArgumentError("at least one simple object is required"))
    length(names) == length(simples) || throw(ArgumentError(
        "names and simples must have the same length"))
    C = parent(first(simples))
    all(X -> parent(X) === C, [generators;simples]) || throw(ArgumentError(
        "generators and simple objects must have the same parent category"))
    is_semisimple(C) && is_tensor(C) || throw(ArgumentError(
        "fusion_subcategory requires a semisimple tensor category"))

    n = length(simples)
    unit_matches = if check
        all(X -> int_dim(End(X)) == 1,simples) || throw(ArgumentError(
            "the supplied objects must be split simple"))
        for i in 1:n, j in i+1:n
            int_dim(Hom(simples[i],simples[j])) == 0 &&
            int_dim(Hom(simples[j],simples[i])) == 0 || throw(ArgumentError(
                "the supplied simple objects must be pairwise nonisomorphic"))
        end
        matches = findall(X -> int_dim(Hom(X,one(C))) != 0,simples)
        length(matches) == 1 || throw(ArgumentError(
            "the supplied simple objects must contain the tensor unit exactly once"))
        for G in generators
            generator_matches = findall(X -> int_dim(Hom(G,X)) != 0,simples)
            length(generator_matches) == 1 && int_dim(End(G)) == 1 ||
                throw(ArgumentError(
                    "each generator must be one of the supplied split simple objects"))
        end
        for X in simples
            count(Y -> int_dim(Hom(dual(X),Y)) != 0,simples) == 1 ||
                throw(ArgumentError(
                    "the supplied simple objects must be closed under duality"))
        end
        matches
    else
        matches = findall(==(one(C)),simples)
        length(matches) == 1 || throw(ArgumentError(
            "with check=false, simples must contain the tensor unit literally once"))
        for G in generators
            count(==(G),simples) == 1 || throw(ArgumentError(
                "with check=false, every generator must occur literally once in simples"))
        end
        matches
    end

    matrices = _fusion_subcategory_product_matrices(products,length(generators),n)
    if matrices === nothing
        matrices = [[int_dim(Hom(S,G⊗X)) for S in simples, X in simples]
                    for G in generators]
    end

    if check
        for (G,M) in zip(generators,matrices), j in 1:n
            decomposition = [(simples[k],M[k,j]) for k in 1:n if M[k,j] != 0]
            decomposition_isomorphism(G⊗simples[j],decomposition;rng)
        end
    end

    reached = Set(unit_matches)
    while true
        new_reached = Set(k for M in matrices for j in reached for k in 1:n if M[k,j] != 0)
        old_length = length(reached)
        union!(reached,new_reached)
        length(reached) == old_length && break
    end
    length(reached) == n || throw(ArgumentError(
        "the supplied generators do not reach every proposed simple object"))

    D = FusionSubcategory(C,Object[simples...],names)
    skeletal || return D
    F = six_j_category(D,TensorCategories.simples(D),names;check)
    set_name!(F,"Fusion subcategory generated by " * join(string.(generators),", "))
    F
end

fusion_subcategory(generator::Object; kwargs...) =
    fusion_subcategory(Object[generator];kwargs...)

function six_j_symbols(C::Category,S=simples(C);homs=nothing)
    _require_split_semisimple_coordinates(C,"F-symbol computation",S)

    N = length(S)
    C_morphism_type = morphism_type(C)
    F = base_ring(C) 

    ass = Array{MatElem}(undef,N,N,N,N)

    one_indices = findall(s -> int_dim(Hom(s,one(C))) > 0 , S)
    if homs === nothing
        # Normalize unit representatives before choosing the corresponding
        # multiplicity-space bases.
        S[one_indices] = simple_subobjects(one(C))
        homs = multiplicity_spaces(C,S)
    end

    prods = [domain(homs[(i,j,findfirst(k -> haskey(homs, (i,j,k)), 1:N))]) for i ∈ 1:N, j in 1:N]

    homs = Dict(k => (basis(v)) for (k,v) in homs)
    missed = [(i,j,k) => C_morphism_type[] for i in 1:N, j in 1:N, k in 1:N if !haskey(homs, (i,j,k))]
    if length(missed) > 0
        push!(homs, missed...)
    end

    #associators = [associator(X,Y,Z) for X ∈ S, Y ∈ S, Z ∈ S]



    for i in 1:N 
        for j ∈ 1:N, k ∈ 1:N
            if !isempty([i,j,k] ∩ one_indices) 
                for l ∈ 1:N
                    n = sum([length(homs[i,j,v]) * length(homs[v,k,l]) for v ∈ 1:N])
                    ass[i,j,k,l] = identity_matrix(F,n)
                end
                continue
            end
            #@show i,j,k
            a = associator((S[[i,j,k]])...)

            for  l ∈ 1:N
                #set trivial associators
                
                #@show i,j,k,l
                # Build a basis for Hom((X⊗Y)⊗Z,W)
                B_XY_Z_W = C_morphism_type[]
                for n ∈ 1:N
                    #@show n
                    V = S[n]

                    H_XY_V = homs[i,j,n]

                    H_VZ_W = homs[n,k,l]

                    B = [f ∘ (g ⊗ id(S[k])) for f ∈ H_VZ_W, g ∈ H_XY_V][:]
                    if length(B) == 0 continue end
                    B_XY_Z_W = [B_XY_Z_W; B]
                end

                # Build a basis for Hom(X⊗(Y⊗Z),W)
                B_X_YZ_W = C_morphism_type[]
                for n ∈ 1:N
                    V = S[n]

                    H_YZ_V = homs[j,k,n]

                    H_XV_W = homs[i,n,l]
                            
                    B = [f ∘ (id(S[i]) ⊗ g) for f ∈ H_XV_W, g ∈ H_YZ_V][:]
                    if length(B) == 0 continue end
                    B_X_YZ_W = [B_X_YZ_W; B]
                end

                associator_XYZ_W = hcat([express_in_basis(f ∘ a, B_XY_Z_W) for f ∈ B_X_YZ_W]...)
            
                ass[i,j,k,l] = matrix(F, length(B_XY_Z_W), length(B_X_YZ_W),  associator_XYZ_W)
            end
        end
    end

    return ass           
end

function six_j_symbols_of_construction(C::Category,S=simples(C),mult=nothing;
        log=nothing,homs=nothing)
    _require_split_semisimple_coordinates(C,"F-symbol computation",S)
    if base_ring(C) isa Union{AcbField,ArbField,ComplexField} && !is_unitary(C)
        @warn("Computing F-symbols is buggy for non unitary numeric categories. Check Results afterwards")
    end

    if length(S) == 1 
        ass = Array{MatElem}(undef,1,1,1,1)
        ass[1,1,1,1] = identity_matrix(base_ring(C),1)
        return ass 
    end

    if log !== nothing 
        path = if isabspath(log) 
            log 
        else
            joinpath(@__DIR__, "$log")
        end
        mkdir(path)
    end 

    N = length(S)
    C_morphism_type = morphism_type(category(C))
    F = base_ring(C) 

   # mult = multiplication_table(C)

    ass = Array{MatElem}(undef,N,N,N,N)

    one_indices = findall(s -> int_dim(Hom(s,one(C))) > 0 , S)
    if homs === nothing
        S[one_indices] = simple_subobjects(one(C))
        homs = multiplicity_spaces(C,S)
    end

    # prods = [X ⊗ Y for X ∈ S, Y ∈ S]

    # if mult !== nothing 
    #     global homs = [mult[i,j,k] > 0 ? morphism.(basis(Hom(prods[i,j],S[k]))) : C_morphism_type[] for i ∈ 1:N, j ∈ 1:N, k ∈ 1:N]
    # else
    #     global homs = [morphism.(basis(Hom(prods[i,j],S[k]))) for i ∈ 1:N, j ∈ 1:N, k ∈ 1:N]
    # end  
    
    homs = Dict(k => morphism.(basis(v)) for (k,v) in homs)
    missed = [(i,j,k) => C_morphism_type[] for i in 1:N, j in 1:N, k in 1:N if !haskey(homs, (i,j,k))]
    if length(missed) > 0
        push!(homs, missed...)
    end
    #associators = [associator(object.((X,Y,Z))...) for X ∈ S, Y ∈ S, Z ∈ S]



    for i ∈ 1:N 
        for j ∈ 1:N, k ∈ 1:N
            a = associator(object.(S[[i,j,k]])...)
 
            for l ∈ 1:N
                if log !== nothing && isfile(joinpath(@__DIR__, "$log/$(i)_$(j)_$(k)_$(l)"))
                    _m =  load(joinpath(@__DIR__, "$log/$(i)_$(j)_$(k)_$(l)"))
                    ass[i,j,k,l] = matrix(F, size(_m,1),size(_m,2), collect(_m)) 
                    continue 
                end

                #set trivial associators
                if !isempty([i,j,k] ∩ one_indices) 
                    n = sum([length(homs[i,j,v]) * length(homs[v,k,l]) for v ∈ 1:N])
                    ass[i,j,k,l] = identity_matrix(F,n)

                    if log !== nothing 
                        if typeof(base_ring(C)) <: Union{ArbField,AcbField}
                            Oscar.Serialization.serialize(joinpath(path,"$(i)_$(j)_$(k)_$(l)"), ComplexF64.(collect(ass[i,j,k,l])))
                        else
                            save( joinpath(@__DIR__, "$log/$(i)_$(j)_$(k)_$(l)"),ass[i,j,k,l])
                        end
                    end
                    continue
                end

                # Build a basis for Hom((X⊗Y)⊗Z,W)
                B_XY_Z_W = C_morphism_type[]
                for n ∈ 1:N
                    V = S[n]

                    H_XY_V = homs[i,j,n]
                    H_VZ_W = homs[n,k,l]

                    B = [f ∘ (g ⊗ id(object(S[k]))) for f ∈ H_VZ_W, g ∈ H_XY_V][:]
                    if length(B) == 0 continue end
                    B_XY_Z_W = [B_XY_Z_W; B]
                end

                # Build a basis for Hom(X⊗(Y⊗Z),W) 
                B_X_YZ_W = C_morphism_type[]
                for n ∈ 1:N
                    V = S[n]

                    H_YZ_V = homs[j,k,n]

                    H_XV_W = homs[i,n,l]
                            
                    B = [f ∘ (id(object(S[i])) ⊗ g) for f ∈ H_XV_W, g ∈ H_YZ_V][:]
                    if length(B) == 0 continue end
                    B_X_YZ_W = [B_X_YZ_W; B]
                end
                

                # Express the asociator in the corresponding basis
                #a = associators[i,j,k]

                # if length(B_X_YZ_W) > 1
                #     @show i,j,k,l
                #     return B_XY_Z_W, B_X_YZ_W, a
                # end

                # Use a different method for the numeric case
                associator_XYZ_W = if base_ring(C) isa Union{AcbField,ArbField,ComplexField} && is_unitary(C)
                    # Assumes orthogonal bases
                    correction = [inv(F(f ∘ dagger(f))) for f ∈ B_XY_Z_W]
                    [c * F(f ∘ a ∘ dagger(g)) for (g,c) in zip(B_XY_Z_W, correction), f in B_X_YZ_W]
                else 
                    # Usually faster if solving linear systems is stable
                    hcat([express_in_basis(f ∘ a, B_XY_Z_W) for f ∈ B_X_YZ_W]...)
                end
                
                ass[i,j,k,l] = matrix(F, length(B_XY_Z_W), length(B_X_YZ_W),  associator_XYZ_W) 

                if log !== nothing 
                    if typeof(base_ring(C)) <: Union{ArbField,AcbField}
                        Oscar.Serialization.serialize(joinpath(path,"$(i)_$(j)_$(k)_$(l)"), ComplexF64.(collect(ass[i,j,k,l])))
                    else
                        save( joinpath(@__DIR__, "$log/$(i)_$(j)_$(k)_$(l)"),ass[i,j,k,l])
                    end
                end
            end

        end
    end

    return ass           
end


function skeletal_spherical(C::Category, Homs)
end

function skeletal_braiding(C::Category,S=simples(C);homs=nothing)
    is_braided(C) || throw(ArgumentError(
        "R-symbol computation requires a braided category"))
    _require_split_semisimple_coordinates(C,"R-symbol computation",S)
    homs === nothing && (homs = multiplicity_spaces(C,S))
    
    N = length(S)
    C_morphism_type = morphism_type(C)
    F = base_ring(C) 
    braid = Array{MatElem}(undef,N,N,N)

    homs = Dict(k => (basis(v)) for (k,v) in homs)
    missed = [(i,j,k) => C_morphism_type[] for i in 1:N, j in 1:N, k in 1:N if !haskey(homs, (i,j,k))]
    if length(missed) > 0
        push!(homs, missed...)
    end

    for i ∈ 1:N
        for j ∈ 1:N
            X,Y = S[[i,j]]
            b = braiding(X,Y)
            for l ∈ 1:N
                W = S[l]
                # Basis for Hom(X⊗Y,W)
                B_XY_W = (homs[i,j,l])

                # Basis for Hom(Y⊗X,W)
                B_YX_W = (homs[j,i,l])

                braid_XY_W = if typeof(base_ring(C)) <: Union{ArbField,AcbField} 
                    correction = [inv(F(f ∘ dagger(f))) for f ∈ B_XY_W]
                    [c * F(f ∘ b ∘ dagger(g)) for (g,c) in zip(B_XY_W, correction), f in B_YX_W]
                else
                    hcat([express_in_basis(f ∘ b, B_XY_W) for f ∈ B_YX_W]...)
                end

                braid[i,j,l] = matrix(F, length(B_XY_W), length(B_YX_W), braid_XY_W)
            end
        end
    end
   return braid
end

function skeletal_braiding_of_construction(C::Category, S = simples(C), mult = nothing)
    is_braided(C) || throw(ArgumentError(
        "R-symbol computation requires a braided category"))
    _require_split_semisimple_coordinates(C,"R-symbol computation",S)
    
    N = length(S)
    C_morphism_type = morphism_type(C)
    F = base_ring(C) 
    braid = Array{MatElem}(undef,N,N,N)

    homs = multiplicity_spaces(C) 
    homs = Dict(k => (basis(v)) for (k,v) in homs)
    missed = [(i,j,k) => C_morphism_type[] for i in 1:N, j in 1:N, k in 1:N if !haskey(homs, (i,j,k))]
    if length(missed) > 0
        push!(homs, missed...)
    end

    for (i,j,l) ∈ Base.product(1:N,1:N,1:N)
        X,Y,W = S[[i,j,l]]
        # Basis for Hom(X⊗Y,W)
        B_XY_W = morphism.(basis(homs[i,j,l]))

        # Basis for Hom(Y⊗X,W)
        B_YX_W = morphism.(basis(homs[j,i,l]))

        braid_XY_W = hcat([express_in_basis(f ∘ morphism(braiding(X,Y)), B_XY_W) for f ∈ B_YX_W]...)
        braid[i,j,l] = matrix(F, length(B_XY_W), length(B_YX_W), braid_XY_W)
    end
    return braid
end

#=----------------------------------------------------------
    Gauge Transform  
----------------------------------------------------------=#

# function unitary_gauge(C::SixJCategory)
#     @assert multiplicity(C) == 1
#     N = rank(C) 
#     K = base_ring(C)
    
#     if  ! is_normal(K) 
#         K,emb = normal_closure(K)
#         C = extension_of_scalars(C,K,embedding = emb)
#     end

#     conjg = complex_conjugation(K)

    

#     D = six_j_category(R, multiplication_table(C))
#     D.one = C.one 
#     D.ass = [change_base_ring(R,m) for m in C.ass]
    
#     trafo = Dict((i,j,k) => popfirst!(g) * Hom(D[]))
# end

function gauge_transform(C::SixJCategory, bases::Dict)

    S = simples(C)
    F = base_ring(C)
    N = length(S)

    old_bases = [basis(Hom(x⊗y,z)) for x ∈ S, y ∈ S, z ∈ S]
    new_bases = [(i,j,k) ∈ keys(bases) ? bases[(i,j,k)] : old_bases[i,j,k] for i ∈ 1:N, j ∈ 1:N, k ∈ 1:N]

    new_ass = Array{MatElem,4}(undef,N,N,N,N)

    N = length(S)
    C_morphism_type = morphism_type(C)

    for (i,j,k,l) ∈ Base.product(1:N, 1:N, 1:N, 1:N)

        # Build a basis for Hom((X⊗Y)⊗Z,W)
        B_XY_Z_W = C_morphism_type[]
        for n ∈ 1:N
            V = S[n]

            H_XY_V = new_bases[i,j,n]

            H_VZ_W = new_bases[n,k,l]

            B = [f ∘ (g ⊗ id(S[k])) for f ∈ H_VZ_W, g ∈ H_XY_V][:]
            if length(B) == 0 continue end
            B_XY_Z_W = [B_XY_Z_W; B]
        end


        # Build a basis for Hom(X⊗(Y⊗Z),W)
        B_X_YZ_W = C_morphism_type[]
        for n ∈ 1:N
            V = S[n]

            H_YZ_V = new_bases[j,k,n]

            H_XV_W = new_bases[i,n,l]
                    
            B = [f ∘ (id(S[i]) ⊗ g) for f ∈ H_XV_W, g ∈ H_YZ_V][:]
            if length(B) == 0 continue end
            B_X_YZ_W = [B_X_YZ_W; B]
        end


        a = associator(S[[i,j,k]]...)
        m = hcat([express_in_basis(f ∘ a, B_XY_Z_W) for f ∈ B_X_YZ_W]...)
        new_ass[i,j,k,l] =  matrix(F, length(B_X_YZ_W), length(B_XY_Z_W), m)
    end

    new_C = deepcopy(C)
    new_C.ass = new_ass 
    new_C.base_ring = F
    return new_C 
end


function with_gauge_freedom(C::SixJCategory)
    K = base_ring(C)
    
    one_index = C.one 
    N = length(simples(C)) 

    non_trivial_indices = findall(!=(0), multiplication_table(C))

    R,g = polynomial_ring(K, sum(multiplication_table(C)))
    L = fraction_field(R)
    D = six_j_category(L, multiplication_table(C))
    D.one = C.one 
    D.ass = [change_base_ring(L,m) for m in C.ass]

    # Bases for Hom spaces Hom(ij,k)
    homs = [(i,j,k) => [popfirst!(g) * f for f ∈ basis(Hom(D[i]⊗D[j], D[k]))] for (i,j,k) ∈ Tuple.(non_trivial_indices)]

    return gauge_transform(D, Dict(homs))
end

function _subst_gauge!(C::SixJCategory, x::Vector{<:FracFieldElem})
    N = length(simples(C))
    L = base_ring(C)

    for i ∈ 1:N, j ∈ 1:N, k ∈ 1:N, l ∈ 1:N
        C.ass[i,j,k,l] = matrix(L, size(C.ass[i,j,k,l])..., [numerator(a)(x...)//denominator(a)(x...) for a in C.ass[i,j,k,l]])
    end
end

function _subst_gauge!(C::SixJCategory, ind::Tuple{Int,Int,Int}, x::Vector{<:FracFieldElem})
    N = length(simples(C))
    L = base_ring(C)

    for l ∈ 1:N
        i,j,k = ind
        C.ass[i,j,k,l] = matrix(L, size(C.ass[i,j,k,l])..., [numerator(a)(x...)//denominator(a)(x...) for a in C.ass[i,j,k,l]])
    end
end

function _subst_gauge!(C::SixJCategory, ind::Vector{Int}, x::Vector{<:FracFieldElem})
    N = length(simples(C))
    L = base_ring(C)

    for i ∈ ind, j ∈ ind, k ∈ ind, l ∈ 1:N
        C.ass[i,j,k,l] = matrix(L, size(C.ass[i,j,k,l])..., [numerator(a)(x...)//denominator(a)(x...) for a in C.ass[i,j,k,l]])
    end
end


#=----------------------------------------------------------
    Export Skeletal categories as dicts 
----------------------------------------------------------=#

"""
    save_F_symbols(C::SixJCategory, file; convention=:column_major_packing)

Write exact F-symbols as a Julia dictionary of field-coefficient vectors, with
comments identifying the field and convention. The keyword is forwarded to
[`F_symbols`](@ref). `include(file)` returns coefficient vectors, not field
elements; use `save_fusion_category` for a self-contained, loadable category.
"""
function save_F_symbols(C::SixJCategory, file::String; convention::Symbol=:column_major_packing)
    _save_exact_symbol_dictionary(F_symbols(C; convention),file,convention)
end

"""
    save_R_symbols(C::SixJCategory, file; convention=:column_major_packing)

Write exact R-symbol coefficient vectors as for [`save_F_symbols`](@ref),
forwarding `convention` to [`R_symbols`](@ref).
"""
function save_R_symbols(C::SixJCategory, file::String; convention::Symbol=:column_major_packing)
    _save_exact_symbol_dictionary(R_symbols(C; convention),file,convention)
end

function _save_exact_symbol_dictionary(D, file, convention)
    K = parent(first(values(D)))
    open(file,"w") do io
        if K == QQ
            write(io,"# Field: QQ; coefficients are singleton rational vectors\n")
        else
            pol = polynomial(QQ,collect(coefficients(K.pol)))
            write(io,"# Field with defining polynomial $pol\n# Relative to the basis 1,...,x^$(degree(pol)-1)\n")
        end
        write(io,"# symbol_format_version=1 symbol_convention=$convention\nDict(\n")
        # Coefficient vectors must not be annotated with the field-element type.
        entries = sort!(collect(D);by=first)
        write(io,join(["\t$k => $(K == QQ ? [v] : collect(coefficients(v)))" for (k,v) in entries],",\n"))
        write(io,"\n)\n")
    end
    nothing
end

function save_P_symbols(C::SixJCategory, file::String)  

    P = P_symbols(C)
    S,T = typeof(P).parameters
    pol = polynomial(QQ,collect(coefficients(base_ring(C).pol)))

    open(file, "w") do io
        write(io, "# Field with defining polynomial $pol \n# relative to the basis 1,...,x^$(degree(pol)-1)\n\n ")
        write(io,"Dict{$S,$T}(")

        write(io, join(["\t$k => $(coefficients(v))" for (k,v) in P], ",\n"))

        write(io, "\n)")
    end
    nothing
end
