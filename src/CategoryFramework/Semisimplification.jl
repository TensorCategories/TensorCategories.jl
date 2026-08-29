#=----------------------------------------------------------
    Construct a semisimplification of any
    tensor category.
    Reference: https://doi.org/10.48550/arXiv.1801.04409 
----------------------------------------------------------=#

mutable struct Semisimplification <: Category
    category::Category
    simples::Vector{Object}

    Semisimplification(C::Category) = new(C)
end

struct SemisimplifiedObject <: Object
    parent::Semisimplification
    object::Object
end

struct SemisimplifiedMorphism <: Morphism 
    domain::SemisimplifiedObject
    codomain::SemisimplifiedObject
    morphism::Morphism
end

function morphism(dom::SemisimplifiedObject, cod::SemisimplifiedObject, m::Morphism) 
    SemisimplifiedMorphism(dom,cod, m)
end


function ==(X::Semisimplification, Y::Semisimplification)
    category(X) == category(Y)
end
    
morphism(f::SemisimplifiedMorphism) = f.morphism
object(X::SemisimplifiedObject) = X.object
category(C::Semisimplification) = C.category
base_ring(C::Semisimplification) = base_ring(category(C))

function Semisimplification(X::Object, C::Semisimplification) 
    @assert parent(X) == category(C)
    SemisimplifiedObject(C,X)
end

function Semisimplification(X::Object)
    C = Semisimplification(parent(X))
    SemisimplifiedObject(C,X)
end

function Semisimplification(f::Morphism, C::Semisimplification)
    dom = SemisimplifiedObject(C, domain(f))
    cod = SemisimplifiedObject(C, codomain(f))
    morphism(dom, cod, f)
end

function Semisimplification(f::Morphism)
    C = Semisimplification(parent(domain(f)))
    Semisimplification(f,C)
end

is_abelian(C::Semisimplification) = is_abelian(category(C))
is_semisimple(C::Semisimplification) = true
is_multiring(C::Semisimplification) = is_monoidal(category(C))
is_multifusion(C::Semisimplification) = is_multiring(category(C)) && is_rigid(category(C))
is_ring(C::Semisimplification) = is_multiring(C) && int_dim(End(one(C))) == 1
is_braided(C::Semisimplification) = is_braided(category(C))

dim(X::SemisimplifiedObject) = dim(object(X))

function tr(f::SemisimplifiedMorphism)
    semisimplify(tr(morphism(f)), parent(f))
end

function braiding(X::SemisimplifiedObject, Y::SemisimplifiedObject)
    semisimplify(braiding(object(X), object(Y)), parent(X))
end

semisimplify(C::Category) = Semisimplification(C)
semisimplify(X::Object) = SemisimplifiedObject(Semisimplification(parent(X)), X)
semisimplify(X::Object, C::Semisimplification) = Semisimplification(X, C)

function semisimplify(f::Morphism, C::Semisimplification)   
    dom = semisimplify(domain(f),C)
    cod = semisimplify(codomain(f),C)
    SemisimplifiedMorphism(dom,cod,f)
end

semisimplify(f::Morphism) = semisimplify(f,semisimplify(parent(f)))

#=----------------------------------------------------------
    Morphism functionality 
----------------------------------------------------------=#

function compose(f::SemisimplifiedMorphism...)
    dom = domain(f[1])
    codom = codomain(f[end])
    morphism(dom, codom, compose(morphism.(f)...))
end

function direct_sum(f::SemisimplifiedMorphism...)
    dom = direct_sum(domain.(f)...)[1]
    codom = direct_sum(codomain.(f)...)[1]
    map = direct_sum(morphism.(f)...)
    morphism(dom, codom, map)
end

function tensor_product(f::SemisimplifiedMorphism...)
    dom = tensor_product(domain.(f)...)
    codom = tensor_product(codomain.(f)...)
    map = tensor_product(morphism.(f)...)
    morphism(dom, codom, map)
end

function associator(X::SemisimplifiedObject, Y::SemisimplifiedObject, Z::SemisimplifiedObject)
    C = parent(X)
    a = associator(object.([X,Y,Z])...)
    dom = SemisimplifiedObject(C, domain(a))
    cod = SemisimplifiedObject(C, codomain(a))
    SemisimplifiedMorphism(dom,cod, a)
end

function is_negligible(f::Morphism)
    K = base_ring(f)
    return all(g -> iszero(K(tr(f ∘ g))), Hom(codomain(f), domain(f)))
end

"""
    trace_pairing(H::AbstractHomSpace, K=Hom(codomain(H),domain(H)))
    trace_pairing(X::Object, Y::Object=X)

Matrix of the categorical trace pairing, with rows indexed by `basis(H)`
and columns by the reverse Hom basis. Entry `(i,j)` is `tr(K[j] ∘ H[i])`.
Requires scalar-valued traces. This computes from the supplied objects only.
"""
function trace_pairing(H::AbstractHomSpace, K::AbstractHomSpace=Hom(codomain(H),domain(H)))
    domain(H) == codomain(K) && codomain(H) == domain(K) ||
        throw(ArgumentError("Hom spaces must have opposite endpoints"))
    F = base_ring(H)
    return matrix(F,int_dim(H),int_dim(K),
                  [F(tr(g ∘ f)) for f in basis(H), g in basis(K)])
end

function trace_pairing(X::Object, Y::Object=X)
    H = Hom(X,Y)
    trace_pairing(H,X === Y ? H : Hom(Y,X))
end

"""
    quotient_hom_dimension(X::Object, Y::Object=X)

Dimension of Hom modulo negligible morphisms, computed as the rank of the
trace pairing. A zero categorical dimension alone does not test negligibility.
"""
quotient_hom_dimension(X::Object, Y::Object=X) = rank(trace_pairing(X,Y))

is_negligible(f::SemisimplifiedMorphism) = is_negligible(morphism(f))

function ==(f::SemisimplifiedMorphism, g::SemisimplifiedMorphism)
    domain(f) == domain(g) && codomain(f) == codomain(g) && is_negligible(f-g)
end

# Coordinates in the quotient are determined by the trace pairing, not by
# equality of the underlying matrices (which can differ by a negligible map).
function express_in_basis(f::SemisimplifiedMorphism, B::Vector{SemisimplifiedMorphism})
    F = base_ring(f)
    all(b -> domain(b) == domain(f) && codomain(b) == codomain(f), B) ||
        throw(ArgumentError("basis morphisms must have the same domain and codomain"))
    if isempty(B)
        is_negligible(f) || throw(ArgumentError("morphism is not in the empty span"))
        return elem_type(F)[]
    end
    G = basis(Hom(object(codomain(f)), object(domain(f))))
    M = matrix(F, length(B), length(G), [F(tr(morphism(b) ∘ g)) for b in B, g in G])
    v = matrix(F, 1, length(G), [F(tr(morphism(f) ∘ g)) for g in G])
    return collect(solve(M, v; side=:left))[:]
end

endomorphism_ring(X::SemisimplifiedObject, B::Vector{<:Morphism}=basis(End(X))) =
    endomorphism_ring_by_basis(X, B)


function decompose(X::SemisimplifiedObject)
    # Work locally: enumerating all simples can diverge for a wild category.
    result = Tuple{SemisimplifiedObject,Int}[]
    for (s,m) in decompose(object(X))
        Y = semisimplify(s, parent(X))
        is_zero(Y) && continue
        j = findfirst(t -> int_dim(Hom(Y,t[1])) != 0, result)
        if j === nothing
            push!(result,(Y,m))
        else
            result[j] = (result[j][1],result[j][2]+m)
        end
    end
    return result
end

function Hom(X::SemisimplifiedObject, Y::SemisimplifiedObject, XY = Hom(object(X), object(Y)), YX = X === Y ? XY : Hom(object(Y), object(X)))
    base_XY = basis(XY)
    base_YX = basis(YX)


    F = base_ring(X)

    if length(base_XY) == 0 || length(base_YX) == 0
        return HomSpace(X,Y,SemisimplifiedMorphism[])
    end

    M = trace_pairing(XY,YX)
    r,R = rref(transpose(M))
    if r == 1 && X == Y
        return HomSpace(X,Y, SemisimplifiedMorphism[id(X)])
    end
    # Independent rows of the pairing represent a basis modulo its radical.
    rows = Int[findfirst(j -> !iszero(R[i,j]),eachindex(base_XY)) for i in 1:r]
    HomSpace(X,Y,SemisimplifiedMorphism[morphism(X,Y,base_XY[i]) for i in rows])
end

function semisimplify(H::AbstractHomSpace)
    if domain(H) == codomain(H)
        X = semisimplify(domain(H))
        return Hom(X,X, H,H)
    end

    YX = Hom(codomain(H), domain(H))
    X = semisimplify(domain(H))
    Y = semisimplify(codomain(H))
    return Hom(X,Y, H, YX)
end


function id(X::SemisimplifiedObject)
    morphism(X,X, id(object(X)))
end

function matrix(f::SemisimplifiedMorphism)
    # This is the matrix of a REPRESENTATIVE upstairs, not faithful quotient
    # coordinates. E.g. the nilpotent N on J2 is nonzero here but zero below.
    # Use express_in_basis(f,Hom(domain(f),codomain(f))) for quotient coordinates.
    matrix(morphism(f))
end

function zero_morphism(X::SemisimplifiedObject, Y::SemisimplifiedObject)
    morphism(X,Y, zero_morphism(object(X), object(Y)))
end

# Solve f*g*f=f in quotient coordinates. This is a linear system, including
# over nonsplitting fields; no list of simples or decomposition is needed.
function _quotient_generalized_inverse(f::SemisimplifiedMorphism; check::Bool=false)
    X,Y = domain(f),codomain(f)
    is_zero(f) && return zero_morphism(Y,X)
    H,B = basis(Hom(X,Y)),basis(Hom(Y,X))
    F = base_ring(f)
    M = matrix(F,length(B),length(H),
               [c for b in B for c in express_in_basis(f ∘ b ∘ f,H)])
    v = matrix(F,1,length(H),express_in_basis(f,H))
    coefficients = solve(M,v;side=:left)
    g = sum((coefficients[1,j]*b for (j,b) in enumerate(B));
            init=zero_morphism(Y,X))
    check && !(f ∘ g ∘ f == f) && error("invalid quotient generalized inverse")
    return g
end

# Split a quotient idempotent by the Fitting decomposition of 1-e upstairs.
# For N >= dim End(X), ker((1-e)^N) is its generalized zero eigenspace and
# a direct summand of X. Its image in the quotient is precisely im(e).
# Unlike simply quotienting a kernel, this construction uses a split
# decomposition, which the quotient functor does preserve.
function _quotient_idempotent_image(e::SemisimplifiedMorphism; check::Bool=false)
    X = domain(e)
    check && !(X == codomain(e) && e ∘ e == e) && throw(ArgumentError("expected an idempotent"))
    if is_zero(e)
        Y = zero(parent(X))
        return Y,zero_morphism(Y,X),zero_morphism(X,Y)
    end
    a = id(object(X))-morphism(e)
    N = max(1,int_dim(End(object(X))))
    K,k = kernel(composition_power(a,N))
    Y,i = semisimplify(K,parent(X)),semisimplify(k,parent(X))
    r = left_inverse(i) ∘ e
    check && !(r ∘ i == id(Y) && i ∘ r == e) && error("invalid quotient idempotent splitting")
    return Y,i,r
end

function kernel(f::SemisimplifiedMorphism; check::Bool=false)
    g = _quotient_generalized_inverse(f; check)
    K,i,_ = _quotient_idempotent_image(id(domain(f))-g ∘ f; check)
    check && !is_zero(f ∘ i) && error("invalid quotient kernel")
    return K,i
end

function cokernel(f::SemisimplifiedMorphism; check::Bool=false)
    g = _quotient_generalized_inverse(f; check)
    K,_,p = _quotient_idempotent_image(id(codomain(f))-f ∘ g; check)
    check && !is_zero(p ∘ f) && error("invalid quotient cokernel")
    return K,p
end
 


#=----------------------------------------------------------
    Object Functionality 
----------------------------------------------------------=#

function direct_sum(X::SemisimplifiedObject...)
    C = parent(X[1])
    S,i,p = direct_sum(object.(X)...)
    S = SemisimplifiedObject(C, S)
    i = [semisimplify(f, C) for f ∈ i]
    p = [semisimplify(f, C) for f ∈ p]
    S,i,p
end

function tensor_product(X::SemisimplifiedObject...)
    T = tensor_product(object.(X)...)
    SemisimplifiedObject(parent(X[1]), T)
end

function zero(C::Semisimplification)
    SemisimplifiedObject(C, zero(category(C)))
end

function one(C::Semisimplification)
    SemisimplifiedObject(C, one(category(C)))
end

function simples(C::Semisimplification)
    isdefined(C, :simples) && return C.simples
    result = SemisimplifiedObject[]
    for x in indecomposables(category(C))
        X = semisimplify(x,C)
        is_zero(X) && continue
        all(Y -> int_dim(Hom(X,Y)) == 0,result) && push!(result,X)
    end
    return C.simples = result
end

# P. Etingof and V. Ostrik, On semisimplification of tensor categories,
# https://arxiv.org/pdf/1801.04409v4, Definition 2.1 (p. 3).
# By this definition, gf=1_X in the quotient iff tr((gf-1_X)e)=0
# for every e in the ORIGINAL End(X), and likewise for fg=1_Y. Use those
# trace equations directly: no quotient Hom/End bases or repeated coordinate
# conversions are needed. The original End trace form may be degenerate;
# this is precisely the negligible ideal we are quotienting by.
# Testing all e also handles nonsplit simples with tr(1)=0 (GF(4)/GF(2)).
function _quotient_inverse(f::SemisimplifiedMorphism)
    X,Y = domain(f),codomain(f)
    x,y,h = object(X),object(Y),morphism(f)
    F = base_ring(f)
    H,EX,EY = basis(Hom(y,x)),basis(End(x)),basis(End(y))
    target = [F(tr(e)) for e in [EX;EY]]
    # Both objects can be negligible even with nonzero original End spaces.
    # In that case the zero map is their (unique) inverse in the quotient.
    if isempty(H)
        return all(iszero,target) ? zero_morphism(Y,X) : nothing
    end
    entries = elem_type(F)[]
    sizehint!(entries,length(H)*length(target))
    for g in H
        gh,hg = g ∘ h,h ∘ g
        append!(entries,(F(tr(gh ∘ e)) for e in EX))
        append!(entries,(F(tr(hg ∘ e)) for e in EY))
    end
    M = matrix(F,length(H),length(target),entries)
    v = matrix(F,1,length(target),target)
    ok,c = Oscar.can_solve_with_solution(M,v;side=:left)
    ok || return nothing
    g = sum((c[1,j]*g for (j,g) in enumerate(H));init=zero_morphism(y,x))
    morphism(Y,X,g)
end

"""
    inv(f::SemisimplifiedMorphism; check=false)

Invert a quotient morphism. A native matrix inverse descends directly when
available. Otherwise solve the defining inverse trace equations on the
original Hom/End bases; this also handles singular or rectangular representatives
whose negligible summands disappear. Noninvertible input has no solution and
is rejected. `check=true` additionally re-evaluates both output identities.
"""
function inv(f::SemisimplifiedMorphism; check::Bool=false)
    h = morphism(f)
    g = nothing
    # Native matrix inverses are much cheaper than constructing quotient Hom
    # spaces. Restrict the fast path to native matrix backends; attempting
    # another Hom-based inverse first could duplicate the expensive work.
    if h isa Union{SixJMorphism,GroupRepresentationMorphism,VectorSpaceMorphism}
        square = h isa SixJMorphism ? domain(h).components == codomain(h).components :
                 int_dim(domain(h)) == int_dim(codomain(h))
        if square
            inverse_h = try
                inv(h)
            catch err
                err isa Union{ArgumentError,ErrorException,DomainError} || rethrow()
                nothing
            end
            inverse_h === nothing || (g = morphism(codomain(f),domain(f),inverse_h))
        end
    end
    g === nothing && (g = _quotient_inverse(f))
    g === nothing && throw(ArgumentError("morphism is not invertible in the quotient"))
    check && !(g ∘ f == id(domain(f)) && f ∘ g == id(codomain(f))) &&
        throw(ArgumentError("morphism is not invertible in the quotient"))
    return g
end

spherical(X::SemisimplifiedObject) = morphism(X,dual(dual(X)), spherical(object(X)))

dual(X::SemisimplifiedObject) = SemisimplifiedObject(parent(X), dual(object(X)))

function ev(X::SemisimplifiedObject)
    e = ev(object(X))
    C = parent(X)
    dom = SemisimplifiedObject(C, domain(e))
    cod = SemisimplifiedObject(C, codomain(e))
    morphism(dom, cod, e)
end

function coev(X::SemisimplifiedObject)
    c = coev(object(X))
    C = parent(X)
    dom = SemisimplifiedObject(C, domain(c))
    cod = SemisimplifiedObject(C, codomain(c))
    morphism(dom, cod, c)
end

function (F::Ring)(f::SemisimplifiedMorphism)
    # In Rep_F5(C5), End(J2)=F5[N]/N^2 and tr(N*h)=0 for every h.
    # Thus [N]=0 and [1+N]=id; converting the representative matrix wrongly
    # rejects both. Solve for a multiple of the QUOTIENT identity instead.
    # P. Etingof, V. Ostrik, On semisimplification of tensor categories,
    # arXiv:1801.04409v4, Definition 2.1 and Proposition 2.4.
    # https://arxiv.org/pdf/1801.04409v4
    is_zero(f) && return zero(F)
    domain(f) == codomain(f) || throw(ArgumentError(
        "scalar conversion requires an endomorphism"))
    return F(only(express_in_basis(f,[id(domain(f))])))
end

#=----------------------------------------------------------
    Printing 
----------------------------------------------------------=#

function show(io::IO, X::SemisimplifiedObject)
    print(io, "Semisimplified: $(object(X))")
end

function show(io::IO, C::Semisimplification)
    print(io, "Semisimplification of $(category(C))")
end
