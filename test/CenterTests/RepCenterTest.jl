#=----------------------------------------------------------
    Test the Center for The Example Rep(G) 
----------------------------------------------------------=#

# This file is currently not included by test/runtests.jl.  Its assertions
# describe intended center behavior but do not contribute to default coverage.
G = alternating_group(4)
F = GF(13)

Rep = representation_category(F,G)

D = center(Rep)
S = simples(D)

# By Definition 7.13.1 of P. Etingof, S. Gelaki, D. Nikshych, and V. Ostrik,
# Tensor Categories, AMS (2015), an object of Z(C) is an object of C equipped
# with a coherent half-braiding.  Every returned center simple must pass it.
@testset "Simples are central" begin
    for s in S
        @test is_central(s)
    end
end

# Morphisms in Z(C) are precisely underlying morphisms compatible with the
# half-braidings.  Tensor products remain in Z(C), so every basis endomorphism
# produced for this center object must satisfy the central-morphism equations.
@testset "Hom spaces are Central" begin
    H = End(S[3]⊗S[4])
    for f ∈ H
        @test is_central(f)
    end
end
