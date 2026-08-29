G = symmetric_group(3)
F = GF(23)

RepG = representation_category(F,G)
simple_objects = simples(RepG)
𝟙,σ,τ = simple_objects

# Since char(F)=23 does not divide |S₃|=6, Maschke's theorem makes Rep_F(S₃)
# semisimple.  Its irreducibles are the trivial, sign, and standard modules of
# dimensions 1, 1, and 2.  See P. Etingof, S. Gelaki, D. Nikshych, and
# V. Ostrik, Tensor Categories, AMS (2015), Remark 4.2.14.
@testset "Simple objects of Rep(S₃)" begin
    @test length(simple_objects) == 3
    @test dim.(simple_objects) == [1,1,2]
   # @test dual.(simple_objects) == simple_objects
end

# The same reference, Proposition 7.14.6 and Example 8.5.4, identifies the
# center with a Drinfeld-double representation category.  Its simples are
# indexed by a conjugacy class and an irreducible representation of its
# centralizer.  Over F₂₃, x²+x+1 is irreducible because 3 does not divide
# |F₂₃×|=22, so C₃ has a trivial module and one two-dimensional simple.
# The three S₃ conjugacy classes therefore contribute 3, 2, and 2 simples.
@testset "Rep center" begin 
    S = simples(center(RepG))
    @test length(S) == 7
end

# Skeletonization must transport the associator along a monoidal equivalence,
# so the pentagon identity remains valid.  The randomized check samples that
# coherence identity; it is not an exhaustive proof for every quadruple.
@testset "Skeletonize center of RepG" begin 
    R = representation_category(GF(13), symmetric_group(3))
    Z = center(R)
    Z = skeletonize(Z)
    @test randomized_pentagon_axiom(Z,3)
end
