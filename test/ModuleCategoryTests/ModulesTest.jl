#=----------------------------------------------------------
    Test sets for internal Module Categories 
----------------------------------------------------------=#

I = ising_category()

𝟙,χ,X = simples(I)

A = separable_algebra_structures(𝟙 ⊕ χ)[1]

M1 = category_of_right_modules(A)

Funcs = category_of_bimodules(A)

# For the separable Ising algebra A=1⊕ψ, the right-module fixture has the
# regular module and two inequivalent σ-supported modules, hence rank 3.  The
# A-bimodules are monoidal under relative tensor product, whose associator must
# obey pentagon coherence.  See P. Etingof, S. Gelaki, D. Nikshych, and
# V. Ostrik, Tensor Categories, AMS (2015), Definitions 7.8.21 and 7.8.25 and
# Exercise 7.8.28; Proposition 7.8.30 gives semisimplicity from separability.
@testset "Modules in Ising" begin
    # The multiplication found on 1⊕ψ satisfies the unit and associativity
    # equations of an algebra object; see EGNO (2015), Definition 7.8.1.
    @test is_algebra(A)
    @test length(simples(M1)) == 3
    @test pentagon_axiom(Funcs)
end
