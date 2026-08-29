# H. Krause, Krull-Schmidt categories and projective covers,
# arXiv:1410.2822v1 (2014), Proposition 2.3, Theorem 4.2, Corollary 4.4.
# https://arxiv.org/pdf/1410.2822v1
# add(X) is controlled by projective modules over End(X). Decomposing the
# regular right module therefore supplies primitive idempotents, even when
# End(X) has a radical. Central idempotents would only give blocks: e.g.
# End(J2 ⊕ J2)=Mat_2(k[t]/t^2) has one block but two indecomposable summands.
function _decompose_finite_object(X::Object, E=basis(End(X)),
                                  A=isempty(E) ? nothing : endomorphism_ring_by_basis(X,E);
                                  check::Bool=false)
    isempty(E) && return Tuple{typeof(X),Int}[]
    F = base_ring(X)
    iso = iso_oscar_gap(F)
    mats = [representation_matrix(a, :right) for a in basis(A)]
    gap_mats = [GAP.GapObj([GAP.GapObj([iso(m[i,j]) for j in 1:dim(A)])
                           for i in 1:dim(A)]) for m in mats]
    M = GAP.Globals.GModuleByMats(GAP.GapObj(gap_mats), codomain(iso))
    parts = GAP.Globals.MTX.Indecomposition(M)
    blocks = [matrix(F, [preimage(iso, part[1][i,j])
                        for i in 1:length(part[1]), j in 1:dim(A)]) for part in parts]
    B = reduce(vcat, blocks)
    # Projection of 1 onto a right-ideal summand gives its primitive idempotent.
    u = matrix(F, 1, dim(A), coefficients(one(A))) * inv(B)
    result = Tuple{typeof(X),Int}[]
    firstrow = 1
    for block in blocks
        rows = firstrow:firstrow+number_of_rows(block)-1
        c = u[:,rows] * block
        e = sum(c[1,j]*E[j] for j in eachindex(E))
        # Right-module projections give idempotents by construction.
        check && !(e ∘ e == e) && error("invalid primitive idempotent")
        s = image(e)[1]
        i = findfirst(t -> is_isomorphic(s,t[1])[1], result)
        if i === nothing
            push!(result,(s,1))
        else
            result[i] = (result[i][1],result[i][2]+1)
        end
        firstrow += number_of_rows(block)
    end
    # Count the actual primitive summands. dim Hom(Y,X)/dim End(Y) is not a
    # multiplicity formula in general: Hom between distinct indecomposables
    # need not vanish (e.g. J1 and J2 in Rep_F5(C5)).
    return result
end

# Solve BOTH inverse identities in categorical Hom coordinates. This works
# without a faithful matrix realization or a semisimplicity assumption.
function _inverse_in_hom(f::Morphism,
                         H=basis(Hom(codomain(f),domain(f))),
                         BX=basis(End(domain(f))), BY=basis(End(codomain(f)));
                         check::Bool=false)
    X,Y = domain(f),codomain(f)
    F = base_ring(f)
    isempty(BX) && isempty(BY) && return zero_morphism(Y,X)
    isempty(H) && return nothing
    M = matrix(F,length(H),length(BX)+length(BY),
        [c for g in H for c in [express_in_basis(g ∘ f,BX);express_in_basis(f ∘ g,BY)]])
    v = matrix(F,1,length(BX)+length(BY),
               [express_in_basis(id(X),BX);express_in_basis(id(Y),BY)])
    ok,c = Oscar.can_solve_with_solution(M,v;side=:left)
    ok || return nothing
    g = sum((c[1,j]*h for (j,h) in enumerate(H));init=zero_morphism(Y,X))
    # The solved linear system already IS the pair of inverse identities.
    check && !(g ∘ f == id(X) && f ∘ g == id(Y)) && error("invalid categorical inverse")
    return g
end

function inv(f::Morphism; check::Bool=false)
    g = _inverse_in_hom(f; check)
    g === nothing && throw(ArgumentError("morphism is not invertible"))
    return g
end

function _is_isomorphic_finite_objects(X::Object,Y::Object)
    parent(X) == parent(Y) || return false,nothing
    BX,BY = basis(End(X)),basis(End(Y))
    length(BX) == length(BY) || return false,nothing
    H = basis(Hom(X,Y))
    isempty(H) && return is_zero(X) && is_zero(Y) ?
        (true,zero_morphism(X,Y)) : (false,nothing)
    # Reuse the same coordinate spaces for every candidate inverse.
    reverse_H = basis(Hom(Y,X))
    for f in H
        _inverse_in_hom(f,reverse_H,BX,BY) === nothing || return true,f
    end
    # For indecomposable X, nonisomorphisms X -> Y form a subspace if X and
    # Y are isomorphic: the radical of the local ring End(X) [Krause, Section 4].
    is_indecomposable(X) && return false,nothing
    # Exact finite fallback, modulo nonzero scalar multiples. No failed
    # random search is interpreted as a proof of nonisomorphism.
    F = base_ring(X)
    for i in 1:length(H)-1
        for c in Iterators.product(ntuple(_ -> F,length(H)-i)...)
            f = H[i] + sum((c[j]*H[i+j] for j in eachindex(c));init=zero_morphism(X,Y))
            _inverse_in_hom(f,reverse_H,BX,BY) === nothing || return true,f
        end
    end
    return false,nothing
end
