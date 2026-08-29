# These are integration checks for the packaged AnyonWiki data and loaders;
# the database itself is the fixture, not an independently proved oracle.
# See https://anyonwiki.org/docs for its scope and conventions.  A fusion
# category associator must satisfy the pentagon identity, while a pivotal
# structure must be a monoidal identification with the double dual; see
# P. Etingof, S. Gelaki, D. Nikshych, and V. Ostrik, Tensor Categories,
# AMS (2015), Definition 2.2.8 and Section 4.7.
@testset "AnyonWiki" begin 

    keys = anyonwiki_keys(4)
    
    @testset "Construction Categories" begin

        # A random sample checks that exact database entries load as coherent
        # pivotal categories.  Random sampling is smoke coverage, not an
        # exhaustive validation of all keys or all pentagon equations.
        for k in rand(keys, 10)
            C = anyonwiki(k...)
            @test randomized_pentagon_axiom(C, 3)
            @test is_pivotal(C)
        end
    end

    # Stored center data must still define coherent associators after loading.
    # This test does not recompute these centers from the source categories.
    @testset "Centers of anyonwiki" begin

        # Test loading of random simple centers
        for k in rand(keys, 10)
            C = anyonwiki_center(k...)
            @test randomized_pentagon_axiom(C, 3)
        end
    end

    # Keep one fixed rank-five entry in addition to the random rank-at-most-four
    # sample so the suite always exercises a larger exact fixture.
    @testset "Rank 5"   begin
        C = anyonwiki(5,1,0,1,3,1,2)
        @test randomized_pentagon_axiom(C, 3)
    end

    # These counts describe the packaged database index.  They are a data-file
    # regression contract, not a theorem about classification or completeness.
    @testset "Misc" begin
        @test length(anyonwiki_keys(5)) == 279
        @test length(anyonwiki_keys(5, "unitary")) == 56
    end
end

#=----------------------------------------------------------
    Test the computation of centers of the anyonwiki
----------------------------------------------------------=#

# Objects of the Drinfeld center carry coherent half-braidings and form a
# monoidal category; see EGNO, Definition 7.13.1.  Splitting and skeletonizing
# should transport this monoidal structure.  These tests sample pentagon
# equations after each operation and do not compare a complete center oracle.
@testset "AnyonWiki Center" begin
    keys = anyonwiki_keys(3)
    # For sampled rank-at-most-three inputs, compute the center, split its
    # simples, and skeletonize it; both transported associators must remain
    # coherent on the sampled quadruples.
    @testset "Rank < 4: Computation" begin

        for k in rand(keys, 3)
            C = anyonwiki(k...)
            Z = center(C) 
            Z2, = split(Z)
            Z3 = skeletonize(Z2)
            @test randomized_pentagon_axiom(Z2, 3)
            @test randomized_pentagon_axiom(Z3, 3)
        end
    end

    # This companion check only loads the stored center fixtures; it separates
    # loader failures from failures in center computation and skeletonization.
    @testset "Loading" begin
        for k in rand(keys, 3)
            C = anyonwiki_center(k...)
            @test randomized_pentagon_axiom(C, 3)
        end
    end
end

#=----------------------------------------------------------
    load anyonwiki with other fields
----------------------------------------------------------=#

# Scalar conversion should preserve the polynomial pentagon relations in exact
# target fields.  QQBar and GF(17) are exact here; AcbField uses ball arithmetic,
# so its randomized pentagon result is numerical evidence rather than a proof.
@testset "AnyonWiki with other fields" begin
    # QQBar gives an exact algebraically closed characteristic-zero target.
    @testset "QQBar" begin
        C = anyonwiki(QQBarField(), 3,1,0,1,2,1,1)
        @test randomized_pentagon_axiom(C, 3)
    end

    # GF(17) checks exact reduction into positive characteristic for this entry.
    @testset "finite" begin
        C = anyonwiki(GF(17), 3,1,0,1,2,1,1)
        @test randomized_pentagon_axiom(C, 3)
    end

    # AcbField checks approximate complex-ball evaluation of the same data.
    @testset "AcbField" begin
        C = anyonwiki(AcbField(), 3,1,0,1,2,1,1)
        @test randomized_pentagon_axiom(C, 3)
    end
end

# The save/load tests check that a reloaded fixture still satisfies sampled
# pentagon equations.  They do not assert equality of all source and target
# labels, coefficients, pivotal data, or braiding data.
@testset "Saving and loading" begin

    # Numeric export passes through finite-precision ball approximations, hence
    # this assertion is a compatibility check at the requested precision.
    @testset "Numeric" begin
        mktempdir() do path

            # CSV rows are ordered lexicographically by symbol labels. These
            # dyadic coefficients are exactly representable at this precision.
            K = AcbField(64)
            scalars = Dict([2, 1] => K(3//2, 5//4), [1, 2] => K(-2), [1, 1] => K(0, -1))
            scalar_file = joinpath(path, "scalar-symbols.csv")
            numeric_symbols_to_csv(scalar_file, scalars)
            labels = [parse.(Int, split(line, ", ")[1:2]) for line in readlines(scalar_file)]
            @test labels == [[1, 1], [1, 2], [2, 1]]
            @test numeric_symbols_from_csv(scalar_file, K) == scalars

            C = anyonwiki(4,1,2,4,1,0,1)
            
            num_F_symbs = numeric_F_symbols(C, precision = 64)

            numeric_symbols_to_csv(joinpath(path, "TensorCategories-section7-test"), num_F_symbs)
            D = load_numeric_fusion_category(joinpath(path, "TensorCategories-section7-test"), AcbField(32))
            @test randomized_pentagon_axiom(D, 3)
        end
    end

    # Symbolic export retains exact coefficients; the current assertion still
    # checks only sampled coherence of the result, not a field-by-field diff.
    @testset "Symbolic" begin
        mktempdir() do path
            C = anyonwiki(4,1,2,4,1,0,1)
            
            save_fusion_category(C, path, "TensorCategories-section7-test")
            D = load_fusion_category(joinpath(path, "TensorCategories-section7-test"))
            @test randomized_pentagon_axiom(D, 3)
        end
    end
end
