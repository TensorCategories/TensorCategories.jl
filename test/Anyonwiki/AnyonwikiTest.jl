

@testset "AnyonWiki" begin 

    keys = anyonwiki_keys(4)
    
    @testset "Construction Categories" begin

        # test random categories 
        for k in rand(keys, 10)
            C = anyonwiki(k...)
            @test randomized_pentagon_axiom(C, 3)
            @test is_pivotal(C)
        end
    end

    # Test center loading 
    @testset "Centers of anyonwiki" begin

        # Test loading of random simple centers
        for k in rand(keys, 10)
            C = anyonwiki_center(k...)
            @test randomized_pentagon_axiom(C, 3)
        end
    end

    @testset "Rank 5"   begin
        C = anyonwiki(5,1,0,1,3,1,2)
        @test randomized_pentagon_axiom(C, 3)
    end

    @testset "Misc" begin
        @test length(anyonwiki_keys(5)) == 279
        @test length(anyonwiki_keys(5, "unitary")) == 56
    end
end

#=----------------------------------------------------------
    Test the computation of centers of the anyonwiki
----------------------------------------------------------=#

@testset "AnyonWiki Center" begin
    keys = anyonwiki_keys(3)
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

@testset "AnyonWiki with other fields" begin
    @testset "QQBar" begin
        C = anyonwiki(QQBarField(), 3,1,0,1,2,1,1)
        @test randomized_pentagon_axiom(C, 3)
    end

    @testset "finite" begin
        C = anyonwiki(GF(17), 3,1,0,1,2,1,1)
        @test randomized_pentagon_axiom(C, 3)
    end

    @testset "AcbField" begin
        C = anyonwiki(AcbField(), 3,1,0,1,2,1,1)
        @test randomized_pentagon_axiom(C, 3)
    end
end

# Test saving and loading 
@testset "Saving and loading" begin

    @testset "Numeric" begin
        mktempdir() do path

            C = anyonwiki(4,1,2,4,1,0,1)
            
            num_F_symbs = numeric_F_symbols(C, precision = 64)

            numeric_symbols_to_csv(joinpath(path, "TensorCategories-section7-test"), num_F_symbs)
            D = load_numeric_fusion_category(joinpath(path, "TensorCategories-section7-test"), AcbField(32))
            @test randomized_pentagon_axiom(D, 3)
        end
    end

    @testset "Symbolic" begin
        mktempdir() do path
            C = anyonwiki(4,1,2,4,1,0,1)
            
            save_fusion_category(C, path, "TensorCategories-section7-test")
            D = load_fusion_category(joinpath(path, "TensorCategories-section7-test"))
            @test randomized_pentagon_axiom(D, 3)
        end
    end
end
