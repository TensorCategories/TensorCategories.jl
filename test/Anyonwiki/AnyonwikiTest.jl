

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

end

#=----------------------------------------------------------
    Test the computation of centers of the anyonwiki
----------------------------------------------------------=#

@testset "AnyonWiki Center" begin
     
    keys = anyonwiki_keys(4)

    for k in rand(keys, 3)
        C = anyonwiki_center(k...)
        Z = center(C) 
        Z2 = split(Z)
        Z3 = skeletonize(Z2)
        @test randomized_pentagon_axiom(Z2, 3)
        @test randomized_pentagon_axiom(Z3, 3)
    end
end