#=----------------------------------------------------------
    Test the Group action on the Ising Category
----------------------------------------------------------=#

I = ising_category() 
G = cyclic_group(2)
aut = autoequivalences(I)
#  Compute the autoequivalences of the Ising category. There are 2, the identity functor and the identity functor with alternative monoidal structure.
@testset "Autoequivalences of Ising category" begin

    @test length(aut) == 2
    @test all(monoidal_functor_axiom, aut)
end

# Construct a GTensorAction and test basic properties.

a,b = aut    

# decide which one is the identity functor and which one is the nontrivial autoequivalence and fix a to the identity
if length(monoidal_natural_transformations(a,identity_as_monoidal_functor(I))) == 0
    a,b = b,a
end

# the monoidal structure is given by a Dict 
monoidal_str = Dict(
    (1,1) => id(a),
    (1,2) => id(b),
    (2,1) => id(b),
    (2,2) => monoidal_natural_transformations(b∘b, a)[1] # the nontrivial monoidal structure on the identity functor
)
T = gtensor_action(I, elements(G), [a,b], monoidal_str)

@testset "GTensorAction on Ising category" begin    

    @test is_tensor_action(T) 
    @test length(monoidal_natural_transformations(b∘b, a)) == 2
    @test length(monoidal_natural_transformations(a∘a, a)) == 2
    @test length(monoidal_natural_transformations(a∘b, b)) == 2
    @test length(monoidal_natural_transformations(b∘a, b)) == 2
    @test length(monoidal_natural_transformations(b∘b, b)) == 0
end
