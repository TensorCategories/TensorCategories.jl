#=----------------------------------------------------------
    Compute Natrural Transformations in finitary categories. 
----------------------------------------------------------=#
abstract type NaturalTransformation <: Morphism end

mutable struct AdditiveNaturalTransformation <: NaturalTransformation
    domain::AbstractFunctor 
    codomain::AbstractFunctor 
    indecomposables::Vector{<:Object}
    maps::Vector{<:Morphism} 
end

function AdditiveNaturalTransformation(F::AbstractFunctor, G::AbstractFunctor, indecs::Vector{<:Object}, maps::Vector{<:Pair})
    components = Dict(maps)
    maps = [get(components,x,zero_morphism(F(x),G(x))) for x ∈ indecs]
    AdditiveNaturalTransformation(F,G,indecs,maps)
end

struct NaturalTransformations <: AbstractHomSpace
    X::AbstractFunctor
    Y::AbstractFunctor
    basis::Vector{<:NaturalTransformation}
    parent::VectorSpaces
end

#=----------------------------------------------------------
    Functionality   
----------------------------------------------------------=#

function compose(η::AdditiveNaturalTransformation...)
    isempty(η) && throw(ArgumentError("at least one natural transformation is required"))
    length(η) == 1 && return η[1]
    all(codomain(η[i]) == domain(η[i+1]) for i in 1:length(η)-1) ||
        throw(ArgumentError("natural transformations are not composable"))
    AdditiveNaturalTransformation(
        domain(η[1]),
        codomain(η[end]),
        indecomposables(η[1]),
        [compose([e(X) for e ∈ η]...) for X ∈ indecomposables(η[1])]
    )
end

function inv(η::AdditiveNaturalTransformation)
    AdditiveNaturalTransformation(codomain(η),domain(η),indecomposables(η),inv.(η.maps))
end

# function getindex(η::AdditiveNaturalTransformation, X::Object)
#     if X ∈ keys(η.maps)
#         return η.maps[X]
#     end

#     return zero_morphism(domain(η)(X), codomain(η(X)))
# end

function indecomposables(η::AdditiveNaturalTransformation)
    η.indecomposables
end

function id(F::AbstractFunctor)
    indecs = indecomposables(domain(F))
    AdditiveNaturalTransformation(
        F,
        F,
        indecs,
        [id(F(x)) for x ∈ indecs]
    )
end

function (η::AdditiveNaturalTransformation)(X::Object)
    indecs = indecomposables(η)
 
    i = findfirst(x -> x == X, indecs)

    i !== nothing && return η.maps[i]

    _,_,i,p = direct_sum_decomposition(X, indecs)
    F,G = domain(η), codomain(η)
    
    sum((G(iᵢ) ∘ η(domain(iᵢ)) ∘ F(pᵢ) for (iᵢ,pᵢ) ∈ zip(i,p)); init=zero_morphism(F(X),G(X)))
end

function *(x, η::AdditiveNaturalTransformation)
    AdditiveNaturalTransformation(
        domain(η),
        codomain(η),
        indecomposables(η),
        x .* η.maps
    )
end

function +(η::AdditiveNaturalTransformation, ν::AdditiveNaturalTransformation)
    domain(η) == domain(ν) && codomain(η) == codomain(ν) ||
        throw(ArgumentError("natural transformations have different functor endpoints"))
    S = indecomposables(η)
    AdditiveNaturalTransformation(domain(η),codomain(η),S,[η(X)+ν(X) for X in S])
end

function ==(η::AdditiveNaturalTransformation, ν::AdditiveNaturalTransformation)
    domain(η) == domain(ν) && codomain(η) == codomain(ν) || return false
    S,T = indecomposables(η),indecomposables(ν)
    length(S) == length(η.maps) && length(T) == length(ν.maps) || return false
    # Checking both families avoids zip truncation and permits reordered families.
    all(η(X) == ν(X) for X in union(S,T))
end

#=----------------------------------------------------------
    Compute natural transformations 
----------------------------------------------------------=#

function Nat(F::AbstractFunctor, G::AbstractFunctor; indecomposables=nothing)
    domain(F) == domain(G) && codomain(F) == codomain(G) ||
        throw(ArgumentError("functors must have the same domain and codomain"))
    is_additive(F) && is_additive(G) ||
        throw(ArgumentError("the natural-transformation solver requires additive functors"))
    nats = additive_natural_transformations(F,G,indecomposables)
    NaturalTransformations(F,G,nats,VectorSpaces(base_ring(codomain(F))))
end

function additive_natural_transformations(F::AbstractFunctor, G::AbstractFunctor, indecs=nothing)
    domain(F) == domain(G) && codomain(F) == codomain(G) ||
        throw(ArgumentError("functors must have the same domain and codomain"))
    C = domain(F)
    K = base_ring(codomain(F))
    base_ring(C) == K || throw(ArgumentError("the solver currently requires functors over the same base field"))
    indecs === nothing && (indecs = indecomposables(C))
    all(X -> parent(X) == C,indecs) || throw(ArgumentError("generators outside the functor domain"))
    # EGNO, §1.1: G(f)η_X = η_Y F(f) for EVERY f:X→Y. The old solver
    # only checked endomorphisms and summed their constraints. On Rep(A2)
    # it incorrectly allowed independent scalars on the three indecomposables.
    nat_bases = [basis(Hom(F(X),G(X))) for X in indecs]
    offsets = cumsum([0;length.(nat_bases)])
    nvars = last(offsets)
    rows = Vector{elem_type(K)}[]
    for (i,X) in enumerate(indecs), (j,Y) in enumerate(indecs)
        B = basis(Hom(F(X),G(Y)))
        for f in basis(Hom(X,Y))
            M = zero_matrix(K,length(B),nvars)
            for (l,η) in enumerate(nat_bases[i])
                coeffs = express_in_basis(G(f) ∘ η,B)
                for k in eachindex(coeffs)
                    M[k,offsets[i]+l] += coeffs[k]
                end
            end
            for (l,η) in enumerate(nat_bases[j])
                coeffs = express_in_basis(η ∘ F(f),B)
                for k in eachindex(coeffs)
                    M[k,offsets[j]+l] -= coeffs[k]
                end
            end
            append!(rows,[collect(M[k,:])[:] for k in 1:number_of_rows(M)])
        end
    end
    # nullspace takes equations in ROWS and unknowns in COLUMNS.
    M = zero_matrix(K,length(rows),nvars)
    for i in eachindex(rows),j in 1:nvars
        M[i,j] = rows[i][j]
    end
    d,N = nullspace(M)
    NaturalTransformation[AdditiveNaturalTransformation(F,G,indecs,
        [sum((N[offsets[i]+j,l]*b for (j,b) in enumerate(B));
             init=zero_morphism(F(indecs[i]),G(indecs[i])) )
         for (i,B) in enumerate(nat_bases)]) for l in 1:d]
end

function group_indecomposables(indecs::Vector{T}) where T <: Object
    
    G = graph_from_adjacency_matrix(Directed, [int_dim(Hom(x,y)) > 0 for x ∈ indecs, y ∈ indecs])

    groups = weakly_connected_components(G)

    return [indecs[g] for g ∈ groups]
end


#=----------------------------------------------------------
    Monoidal structures     
----------------------------------------------------------=#

function horizontal_composition(η::AdditiveNaturalTransformation, ν::AdditiveNaturalTransformation)
    F,F2 = domain.([η, ν])
    G,G2 = codomain.([η, ν])

    FF = compose(F,F2)
    GG = compose(G,G2)

    indecs = indecomposables(η)

    maps = [ν(G(x)) ∘ F2(η(x)) for x ∈ indecs]

    AdditiveNaturalTransformation(
        FF,
        GG,
        indecs,
        maps
    )
end

tensor_product(η::AdditiveNaturalTransformation, ν::AdditiveNaturalTransformation) = horizontal_composition(ν, η)
#=----------------------------------------------------------
    Pretty Printing 
----------------------------------------------------------=#

function show(io::IO, η::NaturalTransformation)
    print(io, "Natural transformation")
end





