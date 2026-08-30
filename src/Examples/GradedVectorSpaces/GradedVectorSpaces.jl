
mutable struct GradedVectorSpaces <: Category
    base_ring::Field
    base_group::Group
    twist::Cocycle{3}
    spherical::Dict{<:GroupElem, <:FieldElem}
    braiding
end

struct GVSObject <: VectorSpaceObject
    parent::GradedVectorSpaces
    V::VectorSpaceObject
    grading::Vector{<:GroupElem}
end

struct GVSMorphism <: VectorSpaceMorphism
    domain::GVSObject
    codomain::GVSObject
    m::MatElem
end

"""
    graded_vector_spaces(F::Field, G::Group)

The category of ```G```-graded vector spaces.
"""
function graded_vector_spaces(F::Field, G::Group)
    c = trivial_3_cocycle(G,F)

    graded_vector_spaces(F,G,c)
end

function graded_vector_spaces(F::Field, G::Group, χ::BilinearForm)
    @assert is_abelian(G)

    c = trivial_3_cocycle(G,F)

    GradedVectorSpaces(F, G, c, Dict([g => one(F) for g ∈ G]), χ)
end


function graded_vector_spaces(F::Field, G::Group, c::Cocycle)
    χ = nothing
    try
        χ = trivial_bilinear_form(G,F)
    catch
    end
    GradedVectorSpaces(F,G,c, Dict([g => inv(c(g,inv(g),g)) for g ∈ G]), χ)
end

function graded_vector_spaces(G::Group)
    graded_vector_spaces(QQ, G)
end
"""
    VectorSpaceObject(V::Pair{<:GroupElem, <:VectorSpaceObject}...)

TBW
"""
function VectorSpaceObject(V::Pair{<:GroupElem, <:VectorSpaceObject}...)
    W,_,_ = direct_sum([v for (_,v) ∈ V])
    G = parent(V[1][1])
    grading = vcat([[g for _ ∈ 1:int_dim(v)] for (g,v) ∈ V]...)
    C = graded_vector_spaces(base_ring(W), G)
    return GVSObject(C, W, grading)
end

function getindex(C::GradedVectorSpaces, g::GroupElem...)
    GVSObject(C,VectorSpaceObject(VectorSpaces(base_ring(C)), length(g)), [g...])
end

function get_indec(C::GradedVectorSpaces, g::Vector{<:GroupElem})
    C[g...]
end

is_fusion(C::GradedVectorSpaces) = true

basis(X::GVSObject) = basis(X.V)

grading(V::GVSObject) = V.grading
twist(C::GradedVectorSpaces) = C.twist

is_braided(C::GradedVectorSpaces) = C.braiding !== nothing

"""
    function morphism(V::GVSObject, Y::GVSObject, m::MatElem)

Return the morphism ``V → W``defined by ``m``.
"""
function morphism(X::GVSObject, Y::GVSObject, m::MatElem)
    parent(X) == parent(Y) ||
        throw(ArgumentError("mismatching graded categories"))
    size(m) == (int_dim(X),int_dim(Y)) ||
        throw(ArgumentError("mismatching dimensions"))
    base_ring(m) == base_ring(X) ||
        throw(ArgumentError("mismatching base fields"))
    if !isgraded(X,Y,m)
        throw(ErrorException("Matrix does not define graded morphism"))
    end
    return GVSMorphism(X,Y,m)
end

"""
    function one(C::GradedVectorSpaces)

Return ``k`` as the one dimensional graded vector space.
"""
one(C::GradedVectorSpaces) = GVSObject(C,VectorSpaceObject(base_ring(C),1), [one(base_group(C))])

"""
    function zero(C::GradedVectorSpaces)

Return the zero diemsnional graded vector space.
"""
zero(C::GradedVectorSpaces) = GVSObject(C,VectorSpaceObject(base_ring(C),0), elem_type(base_group(C))[])

"""
    function is_isomorphic(V::GVSObject, W::GVSObject)

Check whether ``V``and ``W``are isomorphic as ``G``-graded vector spaces and return an
isomorphism in the positive case.
"""
function is_isomorphic(X::GVSObject, Y::GVSObject)
    parent(X) == parent(Y) || return false, nothing
    degrees = union(X.grading, Y.grading)
    all(g -> count(==(g), X.grading) == count(==(g), Y.grading), degrees) ||
        return false, nothing
    m = zero_matrix(base_ring(X), int_dim(X), int_dim(Y))
    for g in degrees
        for (i,j) in zip(findall(==(g), X.grading),
                         findall(==(g), Y.grading))
            m[i,j] = 1
        end
    end
    return true, morphism(X,Y,m)
end

function ==(C::GradedVectorSpaces, D::GradedVectorSpaces)
    base_ring(C) == base_ring(D) && base_group(C) == base_group(D) &&
        C.twist == D.twist && C.spherical == D.spherical &&
        C.braiding == D.braiding
end
function ==(V::GVSObject, W::GVSObject)
    if parent(V) == parent(W) && V.grading == W.grading
        return true
    end
    return false
end

function ==(f::GVSMorphism, g::GVSMorphism)
    return domain(f) == domain(g) && codomain(f) == codomain(g) && matrix(f) == matrix(g)
end

dim(V::GVSObject) = base_ring(V)(tr(id(V)))

function spherical(V::GVSObject) 
    DDV = dual(dual(V))
    C = parent(V)
    m = diagonal_matrix([C.spherical[g] for g ∈ grading(V)])
    morphism(V,DDV,m)
end

function set_trivial_spherical!(C::GradedVectorSpaces)
    C.spherical = Dict(g => base_ring(C)(1) for g ∈ base_group(C))
end
#-----------------------------------------------------------------
#   Functionality: Direct Sums
#-----------------------------------------------------------------

"""
    function direct_sum(V::GVSObject, W::GVSObject)

Return the direct sum object ``V⊕W``.
"""
function direct_sum(X::GVSObject, Y::GVSObject)
    W,(ix,iy),(px,py) = direct_sum(X.V, Y.V)
    m,n = int_dim(X), int_dim(Y)
    F = base_ring(X)
    grading = [X.grading; Y.grading]
    j = 1

    Z = GVSObject(parent(X), W, grading)

    ix = morphism(X,Z,matrix(ix))
    iy = morphism(Y,Z,matrix(iy))

    px = morphism(Z,X,matrix(px))
    py = morphism(Z,Y,matrix(py))

    return Z, [ix,iy], [px,py]
end

# function direct_sum(f::GVSMorphism, g::GVSMorphism)
#     dom = domain(f)⊕domain(g)
#     cod = codomain(f)⊕codomain(g)
#     F = base_ring(f)
#     m1,n1 = size(f.m)
#     m2,n2 = size(g.m)
#     m = [f.m zero(matrix_space(F,m1,n2)); zero(matrix_space(F,m2,n1)) g.m]
# end

#-----------------------------------------------------------------
#   Functionality: Tensor Product
#-----------------------------------------------------------------

"""
    function tensor_product(V::GVSObject, W::GVSObject)

Return the tensor product ``V⊗W``.
"""
function tensor_product(X::GVSObject, Y::GVSObject)
    parent(X) == parent(Y) ||
        throw(ArgumentError("mismatching graded categories"))
    W = VectorSpaceObject(parent(X.V), int_dim(X)*int_dim(Y))
    G = base_group(X)
    # In the Kronecker basis the right-hand index varies fastest, while
    # homogeneous degrees multiply from left to right.
    grading = [g*h for h ∈ Y.grading, g ∈ X.grading][:]
    return GVSObject(parent(X), W, length(grading) == 0 ? elem_type(G)[] : grading)
end

function braiding(X::GVSObject, Y::GVSObject)
    twist(parent(X)).m !== nothing && error("Braiding not implemented")
    χ = parent(X).braiding
    K = base_ring(X)
    m = diagonal_matrix(K,elem_type(K)[χ(g,h) for g in grading(X), h ∈ grading(Y)][:])

    # permutation
    p = permutation_matrix(K, perm(sortperm([(i,j) for i ∈ 1:int_dim(X), j ∈ 1:int_dim(Y)][:])))
    
    morphism(X⊗Y,Y⊗X, p * m)
end

#-----------------------------------------------------------------
#   Functionality: Simple Objects
#-----------------------------------------------------------------

"""
    function simples(C::GradedVectorSpaces)

Return a vector containing the simple objects of ``C``.
"""
function simples(C::GradedVectorSpaces)
    K = VectorSpaceObject(base_ring(C),1)
    G = base_group(C)
    n = Int(order(G))
    return [GVSObject(C,K,[g]) for g ∈ G]
end

"""
    function decompose(V::GVSObject)

Return a vector with the simple objects together with their multiplicities ``[V:Xi]``.
"""
function decompose(V::GVSObject)
    simpls = simples(parent(V))
    return filter(e -> e[2] > 0, [(s, int_dim(Hom(s,V))) for s ∈ simpls])
end
#-----------------------------------------------------------------
#   Functionality: (Co)Kernel
#-----------------------------------------------------------------

"""
    function kernel(f::GVSMorphism)

Return the graded vector space kernel of ``f``.
"""
function kernel(f::GVSMorphism)
    F = base_ring(f)
    G = base_group(domain(f))
    X,Y = domain(f),codomain(f)
    n = int_dim(X) - rank(f.m)
    m = zero(matrix_space(F, n, int_dim(X)))
    l = 1
    grading = elem_type(G)[]

    for x ∈ unique(domain(f).grading)
        i = findall(e -> e == x, X.grading)
        j = findall(e -> e == x, Y.grading)

        if length(i) == 0 continue end
        if length(j) == 0
            grading = [grading; [x for _ ∈ i]]
            for k in i
                m[l,k] = F(1)
                l = l +1
            end
            continue
        end

        mx = f.m[i,j]

        k = kernel(mx, side = :left)
        d = number_of_rows(k)

        m[l:l+d-1 ,i] = k
        l = l+d
        grading = [grading; [x for _ ∈ 1:d]]
    end
    K = GVSObject(parent(X), VectorSpaceObject(F,n), grading)
    return K, GVSMorphism(K,domain(f), m)
end

"""
    function cokernel(f::GVSMorphism)

Return the graded vector space cokernel of ``f``.
"""
function cokernel(f::GVSMorphism)
    g = GVSMorphism(codomain(f),domain(f),transpose(f.m))
    C,c = kernel(g)
    return C, GVSMorphism(codomain(f),C, transpose(c.m))
end

#-----------------------------------------------------------------
#   Functionality: Associators
#-----------------------------------------------------------------

"""
    function associator(U::GVSObject, V::GVSObject, W::GVSObject)

return the associator isomorphism ``(U⊗V)⊗W → U⊗(V⊗W)``.
"""
function associator(X::GVSObject, Y::GVSObject, Z::GVSObject)
    C = parent(X)
    twist = C.twist
    elems = elements(base_group(C))

    dom = (X⊗Y)⊗Z
    cod = X⊗(Y⊗Z)

    m = one(matrix_space(base_ring(X),int_dim(dom),int_dim(cod)))

    j = 1
    for x ∈ X.grading, y ∈ Y.grading, z ∈ Z.grading
        m[j,j] = twist(x,y,z)
        j = j+1
    end
    return morphism(dom,cod,m)
end

#-----------------------------------------------------------------
#   Functionality: Duals
#-----------------------------------------------------------------

"""
    function dual(V::GVSObject)

Return the graded dual vector space of ``V``.
"""
function dual(V::GVSObject)
    W = dual(V.V)
    grading = [inv(j) for j ∈ V.grading]
    return GVSObject(parent(V), W, grading)
end

"""
    function ev(V::GVSObject)

Return the evaluation map ``V*⊗V → 𝟙``.
"""
function ev(V::GVSObject)
    dom = dual(V)⊗V
    cod = one(parent(V))
    elems = elements(base_group(V))
    twist = parent(V).twist
    m = [i == j ? inv(twist(g,inv(g),g)) : 0 for (i,g) ∈ zip(1:int_dim(V), V.grading), j ∈ 1:int_dim(V)][:]
    morphism(dom,cod, matrix(base_ring(V), reshape(m,int_dim(dom),1)))
end

#-----------------------------------------------------------------
#   Functionality: Hom-Spaces
#-----------------------------------------------------------------

struct GVSHomSpace <: AbstractHomSpace
    X::GVSObject
    Y::GVSObject
    basis::Vector{VectorSpaceMorphism}
    parent::VectorSpaces
end

"""
    function Hom(V::GVSObject, W::GVSObject)

Return the space of morphisms between graded vector spaces ``V`` and ``W``.
"""
function Hom(V::GVSObject, W::GVSObject)
    G = base_group(V)
    B = VSMorphism[]

    zero_M = matrix_space(base_ring(V), int_dim(V), int_dim(W))

    for x ∈ unique(V.grading)
        V_grading = findall(e -> e == x, V.grading)
        W_grading = findall(e -> e == x, W.grading)


        for i ∈ V_grading, j ∈ W_grading
            m = zero(zero_M)
            m[i,j] = 1
            B = [B; GVSMorphism(V,W,m)]
        end
    end
    return GVSHomSpace(V,W,B,VectorSpaces(base_ring(V)))
end

function isgraded(X::GVSObject, Y::GVSObject, m::MatElem)
    for i in 1:int_dim(X), j in 1:int_dim(Y)
        !iszero(m[i,j]) && X.grading[i] != Y.grading[j] && return false
    end
    true
end

# Categorical dimension is a field element and can vanish or wrap in positive
# characteristic; simplicity of a vector space uses its integer dimension.
is_simple(V::VectorSpaceObject) = int_dim(V) == 1

@doc raw""" 

    Forgetful(C::GradedVectorSpaces, D::VectorSpaces)       

Return the forgetful functor $Vec_G \to Vec$.
"""
function Forgetful(C::GradedVectorSpaces, D::VectorSpaces)
    obj_map = x -> X.V
    mor_map = f -> morphism(domain(f).V, codomain(f).V, f.m)
    return Forgetful(C,D,obj_map, mor_map)
end

# """
#     function id(V::GVSObject)

# description
# """
# id(X::GVSObject) = morphism(X,X,one(matrix_space(base_ring(X),dim(X),dim(X))))

#=----------------------------------------------------------
    Extension of scalars 
----------------------------------------------------------=#

function extension_of_scalars(C::GradedVectorSpaces, L::Ring)
    K = base_ring(C)
    if embedding === nothing && K != QQ && characteristic(K) == 0 
        if K isa AbsSimpleNumField && L isa RelSimpleNumField
            f = L
        else
            if base_field(K) == base_field(L)
                _,f = is_subfield(K,L)
            else
                f = L
            end
        end
    elseif embedding === nothing 
        f = L
    else 
        f = embedding 
    end
    
    if C.twist.m === nothing 
        c = trivial_3_cocycle(C.base_group, L)
    else
        c = Cocycle(C.base_group, Dict(g => f(k) for (g,k) ∈ C.twist.m))
    end
    D = graded_vector_spaces(L, C.base_group, c)
end

function extension_of_scalars(X::GVSObject, L::Ring, parent::GradedVectorSpaces = parent(X) ⊗ L)
    GVSObject(parent, X.V ⊗ L, X.grading)
end

function extension_of_scalars(m::VectorSpaceMorphism, L::Ring, parent::GradedVectorSpaces = parent(X) ⊗ L)
    
    K = base_ring(m)
    if K != QQ && characteristic(K) == 0 
        if K isa AbsSimpleNumField && L isa RelSimpleNumField
            f = L
        else
            if base_field(K) == base_field(L)
                _,f = is_subfield(K,L)
            else
                f = L
            end
        end
    else
        f = L
    end

    mat = matrix(L, size(matrix(m))..., f.(collect(matrix(m))))
    morphism(extension_of_scalars(domain(m), L, parent), extension_of_scalars(codomain(m), L, parent), mat)
end

#=----------------------------------------------------------
    As SixJCategory 
----------------------------------------------------------=#

function six_j_category(V::GradedVectorSpaces)
    G = base_group(V)
    n = Int(order(G))
    elems = elements(G)
    K = base_ring(V)

    mult = Int[g*h == s for  g ∈ elems, h ∈ elems, s ∈ elems]

    C = six_j_category(K, mult, ["$g" for g ∈ elems])

    set_one!(C, [g == one(G) for g ∈ elems])

    for i ∈ 1:n, j ∈ 1:n, k ∈ 1:n
        a = [zero_matrix(K,0,0) for _ ∈ 1:n]
        x = *(elems[[i,j,k]]...)
        l = findfirst(==(x), elems)
        a[l] = matrix(K,1,1,[V.twist(elems[[i,j,k]]...)])
        set_associator!(C,i,j,k,a)
    end

    set_name!(C, "Graded vector spaces over $K with simple objects in $G")

    set_pivotal!(C, [V.spherical[g] for g ∈ elems])
    return C
end
#-----------------------------------------------------------------
#   Pretty Printing
#-----------------------------------------------------------------

function show(io::IO, C::GradedVectorSpaces)
    print(io, "Category of G-graded vector spaces over $(base_ring(C)) where G is $(base_group(C))")
end
function show(io::IO, V::GVSObject)
    elems = elements(base_group(V))
    if int_dim(V) == 0
        print(io, "0")
    else
        print(io, "Graded vector space of dimension $(int_dim(V)) with grading\n$(V.grading)")
    end
end
