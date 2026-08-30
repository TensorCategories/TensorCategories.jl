# A serialized skeletal category must retain the labeled fusion product and
# every chosen coherence datum: unit, associator, braiding, and pivotal
# structure. Lazy storage is an implementation detail and must give the same
# mathematical category as eagerly stored F- and R-symbols.
@testset "Oscar serialization of lazy SixJ data" begin
    N = zeros(Int,2,2,2)
    N[1,1,1] = N[1,2,2] = N[2,1,2] = N[2,2,1] = 1
    C = six_j_category(QQ,N,["1","g"])
    set_one!(C,1)
    set_name!(C,"Vec_C2")
    set_braiding!(C,[identity_matrix(QQ,N[i,j,k])
                     for i in 1:2,j in 1:2,k in 1:2])

    eager_ass, eager_braiding = copy(C.ass), copy(C.braiding)
    set_associator!(C,similar(C.ass))
    set_braiding!(C,similar(C.braiding))
    set_attribute!(C,:six_j_symbol,
                   (i,j,k,l) -> eager_ass[i,j,k,l])
    set_attribute!(C,:r_symbol,
                   (i,j,k) -> eager_braiding[i,j,k])
    @test !isassigned(C.ass,1,1,1,1) &&
          !isassigned(C.braiding,1,1,1)

    mktempdir() do dir
        file = joinpath(dir,"vec-c2.json")
        Oscar.save(file,C)
        D = Oscar.load(file)
        @test multiplication_table(D) == multiplication_table(C)
        @test D.one == C.one && D.pivotal == C.pivotal
        @test simples_names(D) == simples_names(C) && D.name == C.name
        @test all(TensorCategories.six_j_symbol(D,Tuple(I)...) ==
                  TensorCategories.six_j_symbol(C,Tuple(I)...)
                  for I in CartesianIndices(C.ass))
        @test all(TensorCategories.r_symbol(D,Tuple(I)...) ==
                  TensorCategories.r_symbol(C,Tuple(I)...)
                  for I in CartesianIndices(C.braiding))
        @test pentagon_axiom(D) && hexagon_axiom(D)
    end
end

# Objects and morphisms carry coordinates relative to a particular skeletal
# category. A joint round trip must therefore preserve the parent by identity,
# as well as the endpoints and every matrix block of the linear map.
@testset "Oscar serialization of SixJ objects and morphisms" begin
    N = zeros(Int,2,2,2)
    N[1,1,1] = N[1,2,2] = N[2,1,2] = N[2,2,1] = 1
    C = six_j_category(QQ,N,["1","g"])
    set_one!(C,1)
    X = C[1] ⊕ C[1] ⊕ C[2]
    f = morphism(X,X,[matrix(QQ,2,2,[1,2,3,4]),
                      matrix(QQ,1,1,[5])])

    mktempdir() do dir
        file = joinpath(dir,"sixj-family.json")
        Oscar.save(file,(C,X,f))
        D,Y,g = Oscar.load(file)
        @test parent(Y) === D
        @test parent(domain(g)) === D && parent(codomain(g)) === D
        @test Y.components == X.components
        @test domain(g) == Y == codomain(g)
        @test matrices(g) == matrices(f)
    end
end
