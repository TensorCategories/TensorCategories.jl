# Finite-field decomposition must retain the radical of End(X). Central
# idempotents only split blocks, not individual indecomposable summands.
function _decompose_finite_center(X::CenterObject)
    E = basis(End(X))
    isempty(E) && return Tuple{CenterObject,Int}[]
    # Skeletal matrices are faithful and their coordinate reduction is cheap.
    # Other backends retain the categorical basis because a representative
    # matrix need not be faithful in quotient constructions.
    A = category(parent(X)) isa SixJCategory ?
        endomorphism_ring_by_matrices(X,E) :
        endomorphism_ring_by_basis(X,E)
    _decompose_finite_object(X,E,A)
end

function _is_isomorphic_finite_center(X::CenterObject,Y::CenterObject)
    parent(X) == parent(Y) || return false,nothing
    X == Y && return true,id(X)
    is_isomorphic(object(X),object(Y))[1] || return false,nothing

    # Tops and socles reject candidates but do not certify an isomorphism.
    # Use them only when an ambient simple list is already available.
    C = parent(X)
    if isdefined(C,:simples)
        for S in C.simples
            int_dim(Hom(X,S)) == int_dim(Hom(Y,S)) || return false,nothing
            int_dim(Hom(S,X)) == int_dim(Hom(S,Y)) || return false,nothing
        end
    end

    H = basis(Hom(X,Y))
    isempty(H) && return false,nothing
    # Every candidate is central. A central map is invertible precisely when
    # its underlying map is invertible.
    for f in H
        is_invertible(morphism(f)) && return true,f
    end

    # If End(X) is local and X is isomorphic to Y, nonisomorphisms X -> Y
    # form a proper linear subspace. Hence some basis vector would be an
    # isomorphism. Over a finite field the residue division ring is a field.
    A = endomorphism_ring(X)
    D,_ = quo(A,radical(A))
    is_commutative(D) && is_simple(D) && return false,nothing

    # Exact fallback for decomposable objects, modulo nonzero scalar multiples.
    F = base_ring(X)
    for i in 1:length(H)-1
        for c in Iterators.product(ntuple(_ -> F,length(H)-i)...)
            f = H[i] + sum((c[j]*H[i+j] for j in eachindex(c));
                           init=zero_morphism(X,Y))
            is_invertible(morphism(f)) && return true,f
        end
    end
    false,nothing
end
