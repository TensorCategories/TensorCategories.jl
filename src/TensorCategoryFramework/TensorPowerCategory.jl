mutable struct TensorPowerCategory <: Category
    category::Category
    generator::Vector{Object}
    indecomposables::Vector
    degrees::Vector{Int}
    complete::Bool
    max_exponent::Int
    #multiplication_table::Dict

    TensorPowerCategory() = new()

end

"""
    tensor_power_category(X::Object...)
    tensor_power_category(X::Vector{<:Object})

The additive closure of direct summands of tensor words in `X`, including the
unit. Use `indecomposables(C,k)` for words of length at most `k`. This does not
automatically close under extensions, subquotients, or duals.
"""
function tensor_power_category(X::Object...)
    isempty(X) && throw(ArgumentError("at least one generator is required"))
    all(x -> parent(x) == parent(X[1]),X) ||
        throw(ArgumentError("generators must have the same parent"))
    C = TensorPowerCategory()
    C.category = parent(X[1])
    generators = Object[s for x in X for (s,_) in decompose(x)]
    C.generator = isempty(generators) ? generators :
        unique_indecomposables(generators)
    units = Object[s for (s,_) in decompose(one(C.category))]
    C.indecomposables = TensorPowerObject[
        TensorPowerObject(C,s) for s in units]
    C.degrees = zeros(Int,length(units))
    C.complete = isempty(C.generator)
    C.max_exponent = 0
    C
end

tensor_power_category(X::Vector{<:Object}) = tensor_power_category(X...)

function ==(C::TensorPowerCategory, D::TensorPowerCategory)
    category(C) == category(D) && C.generator == D.generator
end

struct TensorPowerObject <: Object 
    parent::TensorPowerCategory
    object::Object
end

struct TensorPowerMorphism <: Morphism
    domain::TensorPowerObject
    codomain::TensorPowerObject
    morphism::Morphism
end

is_additive(::TensorPowerCategory) = true
is_linear(::TensorPowerCategory) = true
is_monoidal(::TensorPowerCategory) = true
is_braided(C::TensorPowerCategory) = is_braided(category(C))

object(X::TensorPowerObject) = X.object
morphism(f::TensorPowerMorphism) = f.morphism
category(C::TensorPowerCategory) = C.category
morphism(X::TensorPowerObject, Y::TensorPowerObject, f::Morphism) = TensorPowerMorphism(X,Y,f)

base_ring(C::TensorPowerCategory) = base_ring(category(C))

dim(X::TensorPowerObject) = dim(object(X))

function tr(f::TensorPowerMorphism)
    t = tr(morphism(f))
    C = parent(f)
    morphism(TensorPowerObject(C,domain(t)),
             TensorPowerObject(C,codomain(t)),t)
end

express_in_basis(f::TensorPowerMorphism,B::Vector{TensorPowerMorphism}) =
    express_in_basis(morphism(f),morphism.(B))

(F::Ring)(f::TensorPowerMorphism) =F(morphism(f))

""" 

    tensor_power(X::Object, k::Int) -> Object

Return the ``k``-th tensor power ``X^{\\otimes k}``.
"""
function tensor_power(X::Object, k::Int)
    if k < 0 
        error("Negative exponent")
    elseif k == 0
        return one(parent(X))
    elseif k == 1
        return X
    end

    if isodd(k)
        return X ⊗ tensor_power(X,k-1)
    else 
        Y = tensor_power(X, div(k,2))
        return Y ⊗ Y
    end
    return Y
end

⊗(X::Object,k::Int) = tensor_power(X,k)

function direct_sum(X::TensorPowerObject...)
    S, incl, proj= direct_sum(object.(X))
    S = TensorPowerObject(parent(X[1]), S)
    incl = [morphism(x, S, i) for (i,x) ∈ zip(incl, X)]
    proj = [morphism(S, x, p) for (p,x) ∈ zip(proj, X)]
    S, incl, proj
end

function tensor_product(X::TensorPowerObject, Y::TensorPowerObject)
    TensorPowerObject(parent(X), tensor_product(object(X), object(Y)))
end

function direct_sum(f::TensorPowerMorphism, g::TensorPowerMorphism)
    dom = domain(f) ⊕ domain(g)
    cod = codomain(f) ⊕ codomain(g)
    morphism(dom,cod, direct_sum(morphism(f), morphism(g)))
end

function tensor_product(f::TensorPowerMorphism, g::TensorPowerMorphism)
    dom = domain(f) ⊗ domain(g)
    cod = codomain(f) ⊗ codomain(g)
    morphism(dom, cod, tensor_product(morphism(f), morphism(g)))
end

function associator(X::TensorPowerObject, Y::TensorPowerObject, Z::TensorPowerObject)
    ass = associator(object.([X,Y,Z])...)
    dom = TensorPowerObject(parent(X), domain(ass))
    cod = TensorPowerObject(parent(X), codomain(ass))
    morphism(dom,cod, ass)
end

inv(f::TensorPowerMorphism) = morphism(codomain(f), domain(f), inv(morphism(f)))

one(C::TensorPowerCategory) = TensorPowerObject(C, one(category(C)))

function id(X::TensorPowerObject) 
    morphism(X,X, id(object(X)))
end

#=----------------------------------------------------------
    Simples/Indecompodables 
----------------------------------------------------------=#

function indecomposable_subobjects(X::TensorPowerObject)
    subs = indecomposable_subobjects(object(X))
    return [TensorPowerObject(parent(X), s) for s ∈ subs]
end

# function simples(C::TensorPowerCategory, k = Inf)
#     indecomposabls = object_type(category(C))[]
#     n1 = 0
#     j = 0
#     X = C.generator
#     Y = one(category(C))
#     while j ≤ k+1
#         indecomposabls = unique_simples([indecomposabls; simple_subobjects(Y)])
#         if length(indecomposabls) == n1
#             indecomposabls = [TensorPowerObject(C,s) for s ∈ indecomposabls]
#             C.indecomposables = indecomposabls
#             C.complete = true
#             C.max_exponent = j-1
#             return indecomposabls
#         end
#         n1 = length(indecomposabls)
#         Y = Y ⊗ X
#         j = j+1
#     end
#     indecomposabls = [TensorPowerObject(C,s) for s ∈ indecomposabls]
#     C.indecomposables = indecomposabls
#     C.complete = false
#     C.max_exponent = k
#     return indecomposabls
# end

function braiding(X::TensorPowerObject, Y::TensorPowerObject)
    b = braiding(object(X), object(Y))
    morphism(X⊗Y,Y⊗X,b)
end

dual(X::TensorPowerObject) = TensorPowerObject(parent(X), dual(object(X)))

function ev(X::TensorPowerObject) 
    evaluation = ev(object(X))
    dom = TensorPowerObject(parent(X), domain(evaluation))
    cod = TensorPowerObject(parent(X), codomain(evaluation))
    morphism(dom, cod, evaluation)
end

function coev(X::TensorPowerObject) 
    coevaluation = coev(object(X))
    dom = TensorPowerObject(parent(X), domain(coevaluation))
    cod = TensorPowerObject(parent(X), codomain(coevaluation))
    morphism(dom, cod, coevaluation)
end

function spherical(X::TensorPowerObject)
    sp = spherical(object(X))
    dom = TensorPowerObject(parent(X), domain(sp))
    cod = TensorPowerObject(parent(X), codomain(sp))
    morphism(dom, cod, sp)
end

zero(T::TensorPowerCategory) = TensorPowerObject(T,zero(category(T)))

function zero_morphism(X::TensorPowerObject, Y::TensorPowerObject)
    morphism(X,Y, zero_morphism(object(X), object(Y)))
end

"""
    indecomposables(C::TensorPowerCategory,k=Inf)

Representatives occurring in tensor words of length at most `k`, with the unit
at depth zero. Results are cached by first occurrence, so a later shallower
query remains shallow. `Inf` runs until closure and need not terminate.
"""
function indecomposables(C::TensorPowerCategory,k=Inf)
    (k isa Integer && k >= 0) || k == Inf ||
        throw(ArgumentError("depth must be a nonnegative integer or Inf"))
    while !C.complete && C.max_exponent < k
        depth = C.max_exponent+1
        frontier = object.(C.indecomposables[C.degrees .== C.max_exponent])
        new_objects = Object[]
        for W in frontier,V in C.generator
            for (s,_) in decompose(W ⊗ V)
                if all(t -> !is_isomorphic(s,object(t))[1],C.indecomposables) &&
                   all(t -> !is_isomorphic(s,t)[1],new_objects)
                    push!(new_objects,s)
                end
            end
        end
        append!(C.indecomposables,
                [TensorPowerObject(C,s) for s in new_objects])
        append!(C.degrees,fill(depth,length(new_objects)))
        C.complete = isempty(new_objects)
        C.max_exponent = depth
    end
    C.indecomposables[C.degrees .<= k]
end

function decompose(X::TensorPowerObject)
    dec = decompose(object(X))
    [(TensorPowerObject(parent(X), x), k) for (x,k) ∈ dec]
end

function decompose(X::TensorPowerObject, S::Vector{TensorPowerObject})
    dec = decompose(object(X), object.(S))
    [(TensorPowerObject(parent(X), x), k) for (x,k) ∈ dec]
end

function kernel(f::TensorPowerMorphism)
    K,incl = kernel(morphism(f))
    K = TensorPowerObject(parent(f), K)
    return K, morphism(K,domain(f), incl)
end

function cokernel(f::TensorPowerMorphism)
    C,proj = cokernel(morphism(f))
    C = TensorPowerObject(parent(f), C)
    return C, morphism(codomain(f), C, proj)
end

function is_isomorphic(X::TensorPowerObject, Y::TensorPowerObject)
    is_iso, iso = is_isomorphic(object(X), object(Y))
    if is_iso
        return true, morphism(X,Y,iso)
    else
        return false, nothing
    end
end

function show(io::IO, C::TensorPowerCategory)
    print(io, "Tensor power category with generator $(C.generator)")
end

function show(io::IO, X::TensorPowerObject)
    print(io, "Tensor power category object: $(object(X))")
end

function show(io::IO, f::TensorPowerMorphism)
    print(io, "Tensor power category morphism:  $(morphism(f))")
end


#=----------------------------------------------------------
    Functionality 
----------------------------------------------------------=#

compose(f::TensorPowerMorphism, g::TensorPowerMorphism) = TensorPowerMorphism(domain(f), codomain(g), compose(morphism(f),morphism(g)))


*(k,f::TensorPowerMorphism) = TensorPowerMorphism(domain(f),codomain(f), k*morphism(f))

+(f::TensorPowerMorphism, g::TensorPowerMorphism) = TensorPowerMorphism(domain(f),codomain(f), morphism(f) + morphism(g))

matrix(f::TensorPowerMorphism) = matrix(morphism(f))

function Hom(X::TensorPowerObject, Y::TensorPowerObject)
    H = Hom(object(X), object(Y))
    B = [TensorPowerMorphism(X,Y,f) for f ∈ basis(H)]
    HomSpace(X,Y,B)
end
