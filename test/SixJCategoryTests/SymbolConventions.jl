# The symbol equations are tested independently of the matrix decoders.
# Reference: P. Bonderson, Non-Abelian Anyons and Interferometry (2007),
# https://thesis.caltech.edu/2447/02/thesis.pdf, (2.6), (2.54), (2.57)-(2.58),
# and the multiplicity-free pentagon (2.77).
module SymbolConventionTests
using TensorCategories, Oscar, Test
const TC = TensorCategories

# Multiplicity-free pentagon (Bonderson (2.77)), with admissibility loops
# selecting the fusion paths for which both factors on the left are defined.
function scalar_pentagons(cat)
    fsymb = F_symbols(cat; convention=:bonderson)
    r = rank(cat)
    mt = multiplication_table(cat)
    K = base_ring(cat)
    getF(v) = fsymb[v]
    checked = 0
    for a in 1:r, b in 1:r, c in 1:r, d in 1:r
        for f in 1:r
            mt[a,b,f] == 0 && continue
            for l in 1:r
                mt[c,d,l] == 0 && continue
                for g in 1:r
                    mt[f,c,g] == 0 && continue
                    for k in 1:r
                        mt[b,l,k] == 0 && continue
                        for e in 1:r
                            mt[g,d,e]*mt[f,l,e]*mt[a,k,e] == 0 && continue
                            lhs = getF([f,c,d,e,g,l])*getF([a,b,l,e,f,k])
                            rhs = K(0)
                            for h in 1:r
                                mt[b,c,h] == 0 && continue
                                mt[a,h,g] == 0 && continue
                                mt[h,d,k] == 0 && continue
                                rhs += getF([a,b,c,g,f,h]) *
                                       getF([a,h,d,e,g,k]) *
                                       getF([b,c,d,k,h,l])
                            end
                            @test lhs == rhs
                            checked += 1
                        end
                    end
                end
            end
        end
    end
    checked
end

# Also check equations with a forced-zero left hand side, using the same
# pentagon identity and admissible external fusion paths.
function zero_lhs_pentagons(C)
    n = rank(C)
    N = multiplication_table(C)
    F = F_symbols(C;convention=:bonderson)
    checked = 0
    for a in 1:n,b in 1:n,c in 1:n,d in 1:n,e in 1:n,f in 1:n,g in 1:n,k in 1:n,l in 1:n
        N[a,b,f]*N[f,c,g]*N[g,d,e]*N[c,d,l]*N[b,l,k]*N[a,k,e] == 0 && continue
        N[f,l,e] == 0 || continue
        rhs = sum((F[[a,b,c,g,f,h]]*F[[a,h,d,e,g,k]]*F[[b,c,d,k,h,l]]
            for h in 1:n if N[b,c,h]*N[a,h,g]*N[h,d,k] != 0);init=base_ring(C)(0))
        @test iszero(rhs)
        checked += 1
    end
    checked
end

# Bonderson (2.57)-(2.58), specialized to multiplicity-free fusion. Both
# directions are checked. The shorthand (2.78)-(2.79) reverses the ordered
# R superscripts relative to (2.57)-(2.58); the asymmetric pointed fixture
# distinguishes these, consistently with the defining R-move (2.54).
# Inverse R means the inverse of the indicated
# braiding, not complex conjugation (the bases need not be unitary).
function scalar_hexagons(C)
    N = multiplication_table(C)
    n = rank(C)
    K = base_ring(C)
    F = F_symbols(C; convention=:bonderson)
    R = R_symbols(C; convention=:bonderson)
    checked = 0
    for a in 1:n, b in 1:n, c in 1:n, d in 1:n, e in 1:n, g in 1:n
        N[c,a,e]*N[e,b,d]*N[a,g,d]*N[c,b,g] == 0 && continue
        lhs = R[[c,a,e]] * F[[a,c,b,d,e,g]] * R[[c,b,g]]
        lhs_inv = inv(R[[a,c,e]]) * F[[a,c,b,d,e,g]] * inv(R[[b,c,g]])
        rhs, rhs_inv = K(0), K(0)
        for f in 1:n
            N[a,b,f]*N[c,f,d] == 0 && continue
            rhs += F[[c,a,b,d,e,f]] * R[[c,f,d]] * F[[a,b,c,d,f,g]]
            rhs_inv += F[[c,a,b,d,e,f]] * inv(R[[f,c,d]]) * F[[a,b,c,d,f,g]]
        end
        @test lhs == rhs
        @test lhs_inv == rhs_inv
        checked += 2
    end
    checked
end

# Check the definition against actual projection morphisms, including every
# multiplicity index. This does not call the dictionary-to-matrix decoders.
function projection_equations(C)
    n = rank(C)
    N = multiplication_table(C)
    H = [basis(Hom(C[a] ⊗ C[b],C[d])) for a in 1:n,b in 1:n,d in 1:n]
    F = F_symbols(C; convention=:bonderson)
    R = R_symbols(C; convention=:bonderson)
    mf = multiplicity(C) == 1
    for a in 1:n,b in 1:n,c in 1:n,d in 1:n
        for f in 1:n, ρ in 1:N[b,c,f], σ in 1:N[a,f,d]
            lhs = H[a,f,d][σ] ∘ (id(C[a]) ⊗ H[b,c,f][ρ]) ∘ associator(C[a],C[b],C[c])
            rhs = zero_morphism(domain(lhs),codomain(lhs))
            for e in 1:n, μ in 1:N[a,b,e], ν in 1:N[e,c,d]
                key = mf ? [a,b,c,d,e,f] : [a,b,c,d,e,μ,ν,f,ρ,σ]
                rhs += F[key] * (H[e,c,d][ν] ∘ (H[a,b,e][μ] ⊗ id(C[c])))
            end
            @test lhs == rhs
        end
    end
    for a in 1:n,b in 1:n,c in 1:n,ν in 1:N[b,a,c]
        lhs = H[b,a,c][ν] ∘ braiding(C[a],C[b])
        rhs = zero_morphism(domain(lhs),codomain(lhs))
        for μ in 1:N[a,b,c]
            key = mf ? [a,b,c] : [a,b,c,μ,ν]
            rhs += R[key] * H[a,b,c][μ]
        end
        @test lhs == rhs
    end
end

@testset "F/R conventions: AnyonWiki Ising category" begin
    C = anyonwiki(3,1,0,1,1,1,1)
    old_ass,old_braid = deepcopy(C.ass),deepcopy(C.braiding)
    D = F_symbols(C)
    F = F_symbols(C; convention=:bonderson)
    @test D == F_symbols(C; convention=:column_major_packing)
    @test D != F
    @test D[[1,3,3,1,1,3]] == F[[1,3,3,1,3,1]] == 1
    @test !haskey(D,[1,3,3,1,3,1])
    # Historical packing cannot be repaired by globally swapping e and f:
    # for this block the two channel sets agree, but the matrix is asymmetric.
    z = gen(base_ring(C))
    s = (z^6-z^2)/2
    t = -(z^6+z^2)/2
    @test s != t
    @test F[[3,3,3,3,1,2]] == D[[3,3,3,3,1,2]] == t
    @test F[[3,3,3,3,2,1]] == D[[3,3,3,3,2,1]] == s
    @test scalar_pentagons(C) == 132
    @test zero_lhs_pentagons(C) == 4
    @test scalar_hexagons(C) > 0
    @test R_symbols(C) == R_symbols(C; convention=:bonderson)
    @test R_symbols(C; convention=:bonderson)[[2,2,1]] == -1 # fermion
    projection_equations(C)
    @test C.ass == old_ass && C.braiding == old_braid
    for f in (F_symbols,R_symbols,numeric_F_symbols,numeric_R_symbols)
        @test_throws ArgumentError f(C; convention=:unknown)
    end
end

# A pointed category with a nontrivial change of binary bases distinguishes
# c_ab from c_ba: symmetric/diagonal R fixtures cannot do this. For additive
# C3 and nonzero normalized t(a,b), the projection basis p'_ab=t(a,b)p_ab
# gives A(a,b,c)=t(b,c)t(a,b+c)/(t(a,b)t(a+b,c)) and
# R(a,b)=t(b,a)/t(a,b). These are a coboundary and its induced braiding.
function pointed_fixture()
    n = 3
    add(a,b) = mod(a+b-2,n)+1
    N = [Int(add(a,b)==c) for a in 1:n,b in 1:n,c in 1:n]
    C = six_j_category(QQ,N,["1","g","g²"])
    set_one!(C,1)
    t = QQ[1 1 1; 1 2 3; 1 5 7]
    for a in 1:n,b in 1:n,c in 1:n
        d = add(add(a,b),c)
        C.ass[a,b,c,d][1,1] = t[b,c]*t[a,add(b,c)]/(t[a,b]*t[add(a,b),c])
    end
    set_braiding!(C,[N[a,b,c] == 0 ? zero_matrix(QQ,0,0) :
        matrix(QQ,1,1,[t[b,a]/t[a,b]]) for a in 1:n,b in 1:n,c in 1:n])
    set_name!(C,"Vec(C3), rescaled binary bases")
    C
end

@testset "R direction and multiplicity indices" begin
    C = pointed_fixture()
    @test R_symbols(C; convention=:bonderson)[[2,3,1]] == QQ(5)/3
    @test R_symbols(C; convention=:bonderson)[[3,2,1]] == QQ(3)/5
    @test scalar_hexagons(C) == 54
    @test pentagon_axiom(C) && hexagon_axiom(C)

    U = TC.su_3_3_subcategory()
    K = base_ring(U)
    E = basis(Hom(U[2] ⊗ U[2],U[2]))
    P = matrix(K,2,2,[1,1,0,1])
    newE = [sum(P[i,j]*E[i] for i in 1:2) for j in 1:2]
    V = TC.gauge_transform(U,Dict((2,2,2)=>newE))
    B = inv(P)*TC.r_symbol(U,2,2,2)*P
    V.braiding[2,2,2] = B
    @test B != transpose(B)
    @test pentagon_axiom(V) && hexagon_axiom(V)
    R = R_symbols(V; convention=:bonderson)
    old = R_symbols(V)
    @test R[[2,2,2,1,2]] == B[1,2] != B[2,1]
    @test old[[2,2,2,1,2]] == B[2,1]
    projection_equations(V)
    for convention in (:column_major_packing,:bonderson)
        @test TC.dict_to_associator(F_symbols(V;convention);convention) == V.ass
        @test TC.dict_to_braiding(R_symbols(V;convention);convention) == V.braiding
    end
end

include("SymbolConventionSerialization.jl")
end # module
