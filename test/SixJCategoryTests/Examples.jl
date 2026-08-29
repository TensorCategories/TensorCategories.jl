#=----------------------------------------------------------
    Test 6j Examples
----------------------------------------------------------=#

# These constructors encode established exact F-symbol examples.  A monoidal
# category requires the pentagon identity, and a proposed braiding additionally
# requires the two hexagon identities.  See P. Etingof, S. Gelaki,
# D. Nikshych, and V. Ostrik, Tensor Categories, AMS (2015), Definitions 2.2.8
# and 8.1.1.  These checks validate the supplied symbols; they do not classify
# all categorifications of the corresponding fusion rings.
@testset "6j-Categories" begin
    # test Ising
    @test pentagon_axiom(ising_category())
    @test hexagon_axiom(ising_category(cyclotomic_field(16)[1]))

    # test Tambara Yamagami for A = [2,2]
    @test pentagon_axiom(tambara_yamagami(2,2))

    # test HaagerupH3
    @test pentagon_axiom(haagerup_H3())

    # test Verlinde Categories
    @test pentagon_axiom(verlinde_category(5))

    # test I2 and I2subcategory
    @test pentagon_axiom(I2(4))
    @test pentagon_axiom(I2subcategory(5))
end
