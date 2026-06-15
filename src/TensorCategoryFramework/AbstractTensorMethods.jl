



#---------------------------------------------------------
#   tensor_product
#---------------------------------------------------------


function tensor_product(X::Object...)
    if length(X) == 1 return X end

    Z = X[1]
    for Y ∈ X[2:end]
        Z = Z⊗Y
    end
    return Z
end

tensor_product(X::T) where T <: Union{Vector,Tuple} = tensor_product(X...)

function tensor_product(V::HomSpace{T}, W::HomSpace{T}) where T <: Object
    [f ⊗ g for f ∈ V, g ∈ W]
end

function tensor_product(f::Morphism, W::HomSpace{T}) where T <: Object
    [f ⊗ g for g ∈ W]
end

function tensor_product(V::HomSpace{T}, g::Morphism) where T <: Object
    [f ⊗ g for f ∈ V]
end

"""
    distribute_left(X::SixJObject, Y::SixJObject, Z::SixJObject)

Return the canonical isomorphism ```(X⊕Y)⊗Z → (X⊗Z)⊕(Y⊗Z)```.
"""
function distribute_left(X::Object, Y::Object, Z::Object)
    XY,(ix,iy),(px,py) = direct_sum(X,Y)
    return  vertical_direct_sum(px⊗id(Z), py⊗id(Z))
end

"""
    distribute_left(X::Vector{O}, Z::O) where O <: Object

Return the canonical isomorphism ```(⨁Xi)⊗Z → ⨁(Xi⊗Z)```.
"""
function distribute_left(X::Vector{O}, Z::O) where O <: Object
    XY,ix,px = direct_sum(X...)
    return vertical_direct_sum([pi⊗id(Z) for pi ∈ px])
end


"""
    distribute_right(X::SixJObject, Y::SixJObject, Z::SixJObject)

Return the canonical isomorphism ```X⊗(Y⊕Z) → (X⊗Y)⊕(X⊗Z)````
"""
function distribute_right(X::Object, Y::Object, Z::Object)
    XY,(iy,iz),(py,pz) = direct_sum(Y,Z)
    return  vertical_direct_sum(id(X)⊗py, id(X)⊗pz)
end

"""
    distribute_right(X::O, Z::Vector{O}) where O <: Object

Return the canonical isomorphism ```Z⊗(⨁Xi) → ⨁(Z⊗Xi)```.
"""
function distribute_right(X::O, Z::Vector{O}) where O <: Object
    XY,ix,px = direct_sum(Z...)
    return vertical_direct_sum([id(X)⊗pi for pi ∈ px])
end

function distribute_left_to_right(X::Vector{T}, Y::Vector{T}) where T <: Object
    X_sum,ix,px = direct_sum(X...)
    Y_sum,iy,py = direct_sum(Y...)
    Z_sum,iz,pz = direct_sum(Z...)
    direct_sum([(pxk ⊗ pyj ⊗ pzi) ∘ (ixk ⊗ iyj ⊗ izi) for (izi, pzi) ∈ zip(iz,pz), (iyj,pyj) ∈ zip(iy,py), (ixk,pxk) ∈ zip(ix,px)][:]...)
end

function distribute_right_to_left(X::Vector{T}, Y::Vector{T}, Z::Vector{T}) where T <: Object
    X_sum,ix,px = direct_sum(X...)
    Y_sum,iy,py = direct_sum(Y...)
    Z_sum,iz,pz = direct_sum(Z...)
    direct_sum([(pxk ⊗ (pyj ⊗ pzi)) ∘ (ixk ⊗ (iyj ⊗ izi)) for (izi, pzi) ∈ zip(iz,pz), (iyj,pyj) ∈ zip(iy,py), (ixk,pxk) ∈ zip(ix,px)][:]...)
end

inv_associator(X::Object, Y::Object, Z::Object) = inv(associator(X,Y,Z))




#=-------------------------------------------------
    Multifusion Categories 
-------------------------------------------------=#

function decompose(C::Category)
    @assert is_multitensor(C)
    one_components = [o for (o,_) in decompose(one(C), simples(C))] 

    if length(one_components) == 1
        return [C]
    end
    S = simples(C)
    structure = [length(filter!(e -> e != zero(C), [𝟙ᵢ⊗s⊗𝟙ⱼ for s ∈ S])) for 𝟙ⱼ ∈ one_components, 𝟙ᵢ ∈ one_components]

    components = []
    comp = [1]
    while Set(vcat(components...)) != Set([i for i ∈ 1:length(one_components)])
        js = findall(e -> e != 0, filter(e -> e != structure[comp[end],comp[end]], structure[:,comp[end]]))
        if length(js) == 0
            components = [components; [comp]]
            k = findfirst(e -> !(e ∈ vcat(components...)), 1:length(one_components))
            if k === nothing
                continue
            end
            comp = [k]
        end
        comp = [comp; js]
    end
    return [RingSubcategory(C,c) for c ∈ components]
end

function multiplicity(C::Category)
    @assert is_multifusion(C)

    m = multiplication_table(C)
    return maximum(m[:])
end


#-------------------------------------------------------
# Duals
#-------------------------------------------------------

left_dual(X::Object) = dual(X)
right_dual(X::Object) = dual(X)

dual(f::Morphism) = left_dual(f)

""" 

    left_dual(f::Morphism)

Return the left dual of a morphism ``f``.
"""
function left_dual(f::Morphism)
    X = domain(f)
    Y = codomain(f)
    a = ev(Y)⊗id(dual(X))
    b = (id(dual(Y))⊗f)⊗id(dual(X))
    c = inv_associator(dual(Y),X,dual(X))
    d = id(dual(Y))⊗coev(X)
    (a)∘(b)∘(c)∘(d)
end


""" 

    tr(f::Morphism)

Compute the left trace of a morphism ``X → X∗∗`` or if the category is
spherical of a morphism ``X → X``.
"""
tr(f::Morphism) = left_trace(f)

pivotal(X::Object) = spherical(X::Object)

""" 

    left_trace(f::Morphism)

Compute the left trace of a morphism ``X → X∗∗`` or if the category is
pivotal of a morphism ``X → X``.
"""
function left_trace(f::Morphism)
    V = domain(f)
    W = codomain(f)
    C = parent(V)

    if V == zero(C) || W == zero(C) return zero_morphism(one(C),one(C)) end
    
    if V == W
        return ev(left_dual(V)) ∘ ((pivotal(V)∘f) ⊗ id(left_dual(V))) ∘ coev(V)
    end
    return ev(left_dual(V)) ∘ (f ⊗ id(left_dual(V))) ∘ coev(V)
end

""" 

    right_trace(f::Morphism)

Compute the right trace of a morphism ``X → ∗∗X`` or if the category is
pivotal of a morphism ``X → X``.
"""
function right_trace(f::Morphism)
    return left_trace(dual(f))

    V = domain(f)
    W = codomain(f)
    dV = right_dual(V)
    _,i = is_isomorphic(left_dual(dV),V)
    _,j = is_isomorphic(right_dual(V), left_dual(right_dual(dV)))
    return (ev(right_dual(dV))) ∘ (j⊗(f∘i)) ∘ coev(right_dual(V))
end

function squared_norm(X::Object)
    dim(X) * dim(dual(X))
end

function invertibles(C::Category)
    @assert is_rigid(C)
    return [s for s ∈ simples(C) if int_dim(End(s ⊗ dual(s))) == 1]
end

function is_invertible(X::Object)
    is_isomorphic(X ⊗ dual(X), one(parent(X)))[1]
end

#-------------------------------------------------------
# pivotal structure
#-------------------------------------------------------

function drinfeld_morphism(X::Object)
     (ev(X)⊗id(dual(dual(X)))) ∘ (braiding(X,dual(X))⊗id(dual(dual(X)))) ∘ inv_associator(X, dual(X), dual(dual(X))) ∘ (id(X)⊗coev(dual(X)))
 end

function left_dim(X::Object) 
    C = parent(X)
    if is_tensor(C)
        return base_ring(X)(left_trace(id(X)))
    elseif is_multitensor(C)
        𝟙 = simple_subobjects(one(C))
        incls = [basis(Hom(𝟙ᵢ, one(C)))[1] for 𝟙ᵢ ∈ 𝟙]
        projs = [basis(Hom(one(C), 𝟙ᵢ))[1] for 𝟙ᵢ ∈ 𝟙]

        return sum([base_ring(X)(p∘left_trace(pivotal(X))∘i) for p ∈ projs, i ∈ incls][:])
    end
    error("No dimension defined")
end

function right_dim(X::Object)
    C = parent(X)
    if is_tensor(C)
        return base_ring(X)(right_trace(id(X)))
    elseif is_multitensor(C)
        𝟙 = simple_subobjects(one(C))
        incls = [basis(Hom(𝟙ᵢ, one(C)))[1] for 𝟙ᵢ ∈ 𝟙]
        projs = [basis(Hom(one(C), 𝟙ᵢ))[1] for 𝟙ᵢ ∈ 𝟙]

        return sum([base_ring(X)(p∘right_trace(pivotal(X))∘i) for p ∈ projs, i ∈ incls][:])
    end
    error("No dimension defined")
end 

dim(X::Object) = left_dim(X)
dim(C::Category) = sum(squared_norm(s) for s ∈ simples(C))
#-------------------------------------------------------
# S-Matrix
#-------------------------------------------------------

""" 

    smatrix(C::Category)

Compute the S-matrix as defined in [EGNO](https://math.mit.edu/~etingof/egnobookfinal.pdf).
"""
function smatrix(C::Category, simples = simples(C))
    @assert is_semisimple(C) "Category has to be semisimple"

    if hasfield(typeof(C), :__attrs) 
        return get_attribute!(C, :smatrix) do
            F = base_ring(C)
            m = [tr(braiding(s,t)∘braiding(t,s)) for s ∈ simples, t ∈ simples]
            try
                return matrix(F,[F(n) for n ∈ m])
            catch
            end
            return matrix(F,m)
        end
    end

    F = base_ring(C)
    m = [tr(braiding(s,t)∘braiding(t,s)) for s ∈ simples, t ∈ simples]
    try
        return matrix(F,[F(n) for n ∈ m])
    catch
    end
    return matrix(F,m)
end

""" 

    normalized_smatrix(C::Category)

Compute the S-matrix normalized by the factor 1/√dim(𝒞).
"""
function normalized_smatrix(C::Category, simples = simples(C))
    d = inv(sqrt(dim(C)))
    K = base_ring(C)
    # if characteristic(K) == 0
    #     f = complex_embeddings(K)[1]
    #     if real(f(d)) < 0
    #         d = -d
    #     end
    # end
    return d * smatrix(C)
end

function tmatrix(C::Category, simples = simples(C))
    F=base_ring(C)
    T=[1//dim(S)*F(tr(braiding(S,dual(S)))) for S in simples]
    return diagonal_matrix(T)
end

#-------------------------------------------------------
# decomposition morphism
#-------------------------------------------------------



#=-------------------------------------------------
    Duals in Fusion Categories
-------------------------------------------------=#

function coev(X::Object)
    if is_simple(X)
        return simple_objects_coev(X)
    end

    C = parent(X)
    𝟙 = one(C)

    summands = vcat([[x for _ ∈ 1:k] for (x,k) ∈ decompose(X)]...)
    dual_summands = dual.(summands)
    d = length(summands)

    c = vertical_direct_sum([i == j ? coev(summands[i]) : zero_morphism(𝟙, summands[j]⊗dual_summands[i]) for j ∈ 1:d, i ∈ 1:d][:])

    distr = direct_sum([distribute_right(x,dual_summands) for x ∈ summands]) ∘ distribute_left(summands, dual(X))

    return distr ∘ c
end

function ev(X::Object)
    if is_simple(X)
        return simple_objects_ev(X)
    end
    C = parent(X)
    𝟙 = one(C)

    summands = vcat([[x for _ ∈ 1:k] for (x,k) ∈ decompose(X)]...)
    dual_summands = dual.(summands)
    d = length(summands)

    e = horizontal_direct_sum([i == j ? ev(summands[i]) : zero_morphism(dual_summands[j]⊗summands[i], 𝟙)  for j ∈ 1:d, i ∈ 1:d][:])

    distr = direct_sum([distribute_right(x,summands) for x ∈ dual_summands]) ∘ distribute_left(dual_summands, X)

    return e ∘ inv(distr) 
end

function simple_objects_coev(X::Object)
    DX = dual(X)
    C = parent(X)
    F = base_ring(C)

    cod = X ⊗ DX

    if X == zero(C) return zero_morphism(one(C), X) end

    return basis(Hom(one(C), cod))[1]
end

function simple_objects_ev(X::Object)
    DX = dual(X)
    C = parent(X)
    F = base_ring(C)

    dom = DX ⊗ X

    if X == zero(C) return zero_morphism(X,one(C)) end

    unscaled_ev = basis(Hom(dom,one(C)))[1]

    factor = F((id(X)⊗unscaled_ev)∘associator(X,DX,X)∘(coev(X)⊗id(X)))

    return inv(factor) * unscaled_ev
end

function exponent(X::Object, bound = Inf)
    m = 1
    𝟙 = one(parent(X))
    Y = X
    while m < bound 
        if int_dim(Hom(𝟙,Y)) > 0
            return m
        end
        m = m+1
        Y = Y⊗X
    end
end

function exponent(C::Category)
    @assert is_multiring(C)
    lcm([exponent(x) for x ∈ indecomposables(C)])
end


function double_dual_monoidal_structure(X::Object, Y::Object)
    compose(
        inv(dual(dual_monoidal_structure(X,Y))),
        dual_monoidal_structure(dual(Y), dual(X))
    )
end

#=-------------------------------------------------
    Frobenius Perron dimension 
-------------------------------------------------=#

function fpdim(X::Object)
    @assert is_semisimple(parent(X))
    S = simples(parent(X))
    n = length(S)

    A = Array{Int,2}(undef,n,n)
    end_dims = [int_dim(End(S[i])) for i ∈ 1:n]
    for i ∈ 1:n
        Y = S[i]
        A[:,i] = [length(basis(Hom(X⊗Y,S[j])))//end_dims[i] for j ∈ 1:n]
    end

    λ = fp_eigenvalue(matrix(QQ, A))
    if base_ring(X) isa Union{ArbField, AcbField}
        base_ring(X)(λ)
    else
        λ
    end
end

function fp_eigenvalue(m::MatrixElem)
    K = QQBarField()

    λ = eigenvalues(K, m)
    filter!(e -> isreal(e), λ)
    return findmax(e -> abs(e), λ)[1]
end

function fpdim(C::Category)
    @assert is_semisimple(C)
    S = simples(C)
    d = int_dim(End(one(C)))
    sum(d .* fpdim.(S).^2 .// (int_dim.(End.(S))))
end


#=----------------------------------------------------------
    Tensor product - Dual adjunction    
----------------------------------------------------------=#

@doc raw""" 

    left_dual_adjunction(f::Morphism, X::Object, Y::Object, Z::Object)   

Return the natural isomorphism ``Hom(X⊗Z,Y) ≃ Hom(X,Y⊗Z*)`` evaluated at 
``f: X⊗Z → Y``.
"""

function left_dual_adjunction(f::Morphism, X::Object, Y::Object, Z::Object)
    (f ⊗ id(dual(X))) ∘ inv_associator(X,Z,Y) ∘ (id(X) ⊗ coev(Z))
end

@doc raw""" 

    inverse_left_dual_adjunction(f::Morphism, X::Object, Y::Object, Z::Object)   

Return the natural isomorphism ``Hom(X,Y⊗Z*) ≃ Hom(X⊗Z,Y)`` evaluated at 
``f: X → Y⊗Z*``.
"""

function inverse_left_dual_adjunction(f::Morphism, X::Object, Y::Object, Z::Object)
    (id(Y) ⊗ ev(Z)) ∘ associator(Y,dual(Z),Z) ∘ (f ⊗ id(Z))
end

#-------------------------------------------------------
# Fusion Categories
#-------------------------------------------------------

function fusion_coefficient(X::Object, Y::Object, Z::Object, check = true)
    check && @assert is_simple(X) && is_simple(Y) && is_simple(Z)
    return div(int_dim(Hom(X ⊗ Y, Z)), int_dim(End(Z)))
end

function fusion_coefficient(C::Category, i::Int, j::Int, k::Int)
    return fusion_coefficient(C[i], C[j], C[k], false)
end

function topologize(X::Object)
    topologize([X])
end

function topologize(S::Vector{<:Object})
    T = tensor_power_category(S)
    object.(indecomposables(T))
end

function is_pivotal(C::Category) 
    if typeof(base_ring(C)) <: Union{ArbField, ComplexField, AcbField}
        return is_pivotal_numeric(C)
    end

    all([pivotal(x)⊗pivotal(y) == double_dual_monoidal_structure(x,y) ∘ pivotal(x ⊗ y) for x ∈ simples(C), y ∈ simples(C)])
end 

function is_pivotal_numeric(C::Category) 
    all([overlaps(matrix(pivotal(x)⊗pivotal(y)), matrix(double_dual_monoidal_structure(x,y) ∘ pivotal(x ⊗ y))) for x ∈ simples(C), y ∈ simples(C)])
end

function F_symbols(C::Category)
    if !is_unitary(C) 
        F_symbols(skeletonize(C))
    end
    
    homs = multiplicity_spaces(C)    
    N = rank(C)
    m = multiplicity(C) 
    mult = multiplication_table(C)

    associators = [associator(C[[a,b,c]]...) for (a,b,c) ∈ collect(Base.product(1:N, 1:N, 1:N))]

    K = base_ring(C) 

    F_dict = Dict{Vector{Int}, elem_type(K)}()

    for (a,b,c,d) ∈ collect(Base.product(1:N, 1:N, 1:N, 1:N))
  
        for e in 1:N, f in 1:N 
            if mult[a,b,e] * mult[e,c,d] * mult[b,c,f] * mult[a,f,d] == 0 
                continue 
            end
        
            for (i,g) in pairs(basis(homs[(e, c, d)]))
                for (j,g2) in pairs(basis(homs[(a, b, e)]))
                    for (i2,h) in pairs(basis(homs[(b, c, f)]))
                        for (j2,h2) in pairs(basis(homs[(a, f, d)]))
                            c1 = inv(K(g ∘ dagger(g)))
                            c2 = inv(K(g2 ∘ dagger(g2)))
                            F = K(compose(
                                c1*dagger(g),
                                c2*dagger(g2) ⊗ id(C[c]),
                                associator(C[[a,b,c]]...),
                                id(C[a]) ⊗ h,
                                h2
                            ))
                            if m == 1
                                F_dict[[a,b,c,d,f,e]] = F
                            else
                                F_dict[[a,b,c,d,f,e,(j2,j),(i2,i)]] = F
                            end
                        end
                    end
                end
            
            end
        end
    end

    return F_dict           
end 


function multiplicity_spaces(C::Category, S::Vector{<:Object} = simples(C))
    mults = [(i,j,k) => Hom(x ⊗ y, z) for (i,x) ∈ pairs(S), (j,y) ∈ pairs(S), (k,z) ∈ pairs(S)]
    Dict(p for p ∈ mults if int_dim(p[2]) > 0)
end
#=----------------------------------------------------------
    Dagger
----------------------------------------------------------=#

function inner_product(f::Morphism, g::Morphism)
    C = parent(f)
    @assert parent(g) == C
    @assert codomain(f) == codomain(g)
    @assert domain(f) == domain(g)

    return sqrt(fp_eigenvalue(matrix((dagger(f) ∘ g))))
end

function norm(f::Morphism)
    maximum(abs.(eigenvalues(matrix(dagger(f) ∘ f))))
end

function orthogonal_basis(V::AbstractHomSpace)
    orthogonal_basis(basis(V))
end

function orthogonal_basis(B::Vector{<:Morphism})
    B_new = [B[1]]
    for v ∈ B[2:end]
        corr = sum([inner_product(b,v)//inner_product(b,b) * b for b ∈ B_new if inner_product(b,b) != 0], init = zero_morphism(domain(B[1]),codomain(B[1])))
        push!(B_new, v - corr)
    end
    B_new
end

function orthonormal_basis(V::AbstractHomSpace)
    orthonormal_basis(basis(V))
end

function orthonormal_basis(V::Vector{<:Morphism})
    B = orthogonal_basis(V)
    K = base_ring(V[1])
    coeffs = [sqrt(inner_product(b,b)) for b ∈ B]
    coeffs = if typeof(K) == AcbField 
        [overlaps(c, K(0)) ? K(0) : inv(c) for c in coeffs]
    else
        [c == 0 ? K(0) : inv(c) for c in coeffs]
    end
    [b * c for (b,c) ∈ zip(B,coeffs)]
end

function normalized_basis(V::AbstractHomSpace)
    B = orthonormal_basis(V)
    [b * sqrt(sqrt((dim(codomain(V))*inv(dim(domain(V)))))) for b ∈ B]
end

function is_unitary(f::Morphism)
    !is_invertible(f) && return false
    id(codomain(f)) == f ∘ dagger(f)
end

function dagger(H::AbstractHomSpace)
    HomSpace(codomain(H), domain(H), dagger.(basis(H)))
end

function orthonormalization(f::Morphism)
    f == 0 && return f

    dom = domain(f)
    cod = codomain(f)
    _,_, i_dom, p_dom = direct_sum_decomposition(dom)
    _,_, i_cod, p_cod = direct_sum_decomposition(cod)

    S = simples(parent(f))
    # collect incl/proj with equal co/domain
    base = [vertical_direct_sum([p ∘ f ∘ i for p ∈ p_cod]) for i ∈ i_dom]
    bases = [typeof(f)[v for v ∈ base if is_isomorphic(s,domain(v))[1]] for s ∈ S]
    filter!(!isempty, bases)


    normal_bases = [orthonormal_basis(b) for b ∈ bases] 

    return horizontal_direct_sum(vcat(normal_bases...))
end

#=----------------------------------------------------------
    Fusion subcategories
----------------------------------------------------------=# 

function simple_fusion_subcategories(C::Category)
    @req is_fusion(C) "Category must be fusion"

    R = split_grothendieck_ring(C)
    
    subs = [(i, _topologize(R[i])) for i ∈ 1:rank(R)]
    filter!(e -> is_simple(fusion_subring(R[e[1]])), subs)

    subs = unique!(e -> e[2], subs)
    return [fusion_subcategory(C[i]) for (i,_) ∈ subs]
end