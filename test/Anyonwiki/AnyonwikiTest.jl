

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