#=------------------------------------------------
    ising_category Category
------------------------------------------------=#

I = ising_category()
a,b,c = simples(I)

# In the order (1, ψ, σ), the Ising rules are ψ²=1, ψσ=σ, and
# σ²=1+ψ.  Expanding bilinearly gives the component vectors [2,1,2]
# for X and [6,5,8] for X⊗Y, so these are independent fusion-ring checks of
# the skeletal object arithmetic.
@testset "Ising: Objects" begin
    X = a^2 ⊕ b ⊕ c^2
    Y = a ⊕ c^2
    @test X == SixJObject(I, [2,1,2])
    @test X⊗Y == SixJObject(I, [6,5,8])
end

# A SixJCategory associator must satisfy the pentagon identity; see
# P. Etingof, S. Gelaki, D. Nikshych, and V. Ostrik, Tensor Categories,
# AMS (2015), Definition 2.2.8.  The first assertion is exhaustive on simples;
# the following two exercise additive objects and multiplicities, whose
# associators are assembled blockwise from the same data.
@testset "Associator" begin
    @test pentagon_axiom(I)
    @test pentagon_axiom(c,c,c^2,c)
    @test pentagon_axiom(c^2,a⊕b,c⊕b,c)
end

#=------------------------------------------------
    I2 
------------------------------------------------=#

B = I2(5)

# The I2 constructor supplies another exact associator fixture.  As above, the
# full simple-object check and one large additive-object check must both obey
# the pentagon identity; neither assertion tests a classification of I2 data.
@testset "I2" begin
    @test pentagon_axiom(B)
    @test pentagon_axiom(B[2]⊕B[3], B[3]⊕B[4]⊕B[7], B[2]⊕B[1]⊕B[2], B[6]^2)
end
