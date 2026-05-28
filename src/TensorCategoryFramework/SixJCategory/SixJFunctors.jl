#=----------------------------------------------------------
    Functors for 6j-Categories building on fusion ring
    morphisms 
----------------------------------------------------------=#

struct SixJFunctor <: AbstractMonoidalFunctor 
    domain::SixJCategory
    codomain::SixJCategory 
    images::Vector{SixJObject}
end

function (F::SixJFunctor)(X::SixJObject)
    n = rank(parent(X))
    direct_sum([F.images[i]^X.components[i] for i ∈ 1:n]...)[1]
end

function ==(F::SixJFunctor, G::SixJFunctor)
    domain(F) == domain(G) && 
    codomain(F) == codomain(G) &&
    F.images == G.images 
end

function functor(C::SixJCategory,D::SixJCategory,images::Vector{SixJObject})
    SixJFunctor(C,D,images)
end

function (F::SixJFunctor)(f::SixJMorphism)

    dom = domain(f)
    cod = codomain(f)

    C = domain(F)
    D = codomain(F)
    
    if dom == zero(C) 
        return zero_morphism(zero(C),F(cod))
    end
    if cod == zero(D) 
        return zero_morphism(F(dom),zero(D))
    end

    dom_dec = vcat([typeof(dom)[C[i] for _ ∈ 1:c] for (i,c) ∈ zip(1:rank(C), dom.components)]...)
    cod_dec = vcat([typeof(cod)[C[i] for _ ∈ 1:c] for (i,c) ∈ zip(1:rank(C), cod.components)]...)



    _, incl, _ = direct_sum(dom_dec)
    _, _, proj = direct_sum(cod_dec)

    Fdom, _, Fproj = direct_sum(F.(dom_dec))
    Fcod, Fincl, _ = direct_sum(F.(cod_dec))

    K = base_ring(C)

    f_components = [Fi ∘ (K(p ∘ f ∘ i) * id(F(domain(i)))) ∘ Fp for (i,Fp) ∈ zip(incl, Fproj), (Fi, p) ∈  zip(Fincl,proj) if domain(i) == codomain(p)][:]

    return sum(f_components[:])
end

indecomposables(F::SixJFunctor) = simples(domain(F))


function compose(F::SixJFunctor, G::SixJFunctor)
    images = G.(F.images)

    SixJFunctor(domain(F), codomain(G), images)
end

#=----------------------------------------------------------
    pretty print 
----------------------------------------------------------=#


function show(io::IO, F::SixJFunctor)
    print(io, """Semisimple Monoidal Functor with 
    domain: $(domain(F))
    codomain: $(codomain(F))""")
end