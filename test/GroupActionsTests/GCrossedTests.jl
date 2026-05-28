#=----------------------------------------------------------
    Test The construction of the G-crossed Product 
        C ⋉ G
----------------------------------------------------------=#

# continue with the Ising category and the ℤ₂-action T from the previous test file

GI = gcrossed_product(I,T)

@testset "G-crossed product of Ising category with ℤ₂" begin
    @test pentagon_axiom(GI)
end