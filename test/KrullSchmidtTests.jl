# Primitive idempotents of End(X) give the Krull--Schmidt summands of X; see
# H. Krause, arXiv:1410.2822v1, Proposition 2.3, Theorem 4.2, Corollary 4.4.
@testset "Finite-field primitive decomposition" begin
    jordan(C,n) = begin
        J = identity_matrix(base_ring(C),n)
        for i in 1:n-1
            J[i,i+1] = 1
        end
        Representation(C,gens(base_group(C)),[J])
    end
    R = representation_category(GF(5),cyclic_group(5))
    J1, J2 = jordan(R,1), jordan(R,2)
    # End(J2)=F5[t]/(t²) is local, so J2 is indecomposable but not simple.
    @test is_indecomposable(J2) && !is_simple(J2)
    @test !is_indecomposable(J1 ⊕ J1)
    @test !is_indecomposable(zero(R))
    # Hom(S,X)/End(S) measures a socle multiplicity outside semisimplicity.
    @test_throws ArgumentError decompose(J2,[J1])
    # Central idempotents split blocks, not primitive summands.
    @test_throws ArgumentError central_primitive_idempotents(End(J2))

    for (X, expected) in ((J2 ⊕ J2,[(J2,2)]),
                          (J1 ⊕ J2,[(J1,1),(J2,1)]))
        # Invoke the generic backend rather than the representation override.
        dec = invoke(decompose,Tuple{Object},X)
        @test length(dec) == length(expected)
        @test all(any(m == n && is_isomorphic(S,T)[1] for (T,n) in dec)
                  for (S,m) in expected)
    end

    A = ArrowCategory(VectorSpaces(GF(5)))
    E = ArrowObject(A,id(one(category(A))))
    # A brick need not be simple; generic nonsemisimple simplicity must defer
    # to the category-specific ArrowObject method.
    @test_throws ArgumentError invoke(is_simple,Tuple{Object},E)
    dec = decompose(E ⊕ E)
    @test length(dec) == 1 && dec[1][2] == 2
    @test is_isomorphic(dec[1][1],E)[1]
    @test isempty(decompose(zero(A)))
    @test inv(id(zero(A))) == id(zero(A))

    C = six_j_category(GF(5),ones(Int,1,1,1),["1"])
    set_one!(C,[1])
    Q = Semisimplification(C)
    U = one(Q)
    # End(U⊕U)=Mat_2(F5) is a simple algebra, but U⊕U is not simple.
    @test is_simple(U) && !is_simple(U ⊕ U)
end
