#=----------------------------------------------------------
    Test Serialization of SixJCategories           
----------------------------------------------------------=#

mktempdir() do path

# Multiplicity free
C1 = anyonwiki(2, 1, 0, 1, 2, 1, 1)
C2 = anyonwiki(3, 1, 0, 1, 1, 1, 1)
C3 = anyonwiki(4, 1, 0, 1, 2, 1, 1)

# multiplicity 2
D = anyonwiki_center(4,1,2,4,1,0,1)

@testset "Save multiplicity free categories" begin 
    save_fusion_category(C1, path, "C1")
    C1_ = load_fusion_category(joinpath(path, "C1"))
    @test randomized_pentagon_axiom(C1_,3)
    rm(joinpath(path, "C1"), recursive = true)

    save_fusion_category(C2, path, "C2")
    C2_ = load_fusion_category(joinpath(path, "C2"))
    @test randomized_pentagon_axiom(C2_,3)
    rm(joinpath(path, "C2"), recursive = true)
    
    save_fusion_category(C3, path, "C3")
    C3_ = load_fusion_category(joinpath(path, "C3"))
    @test randomized_pentagon_axiom(C3_,3)
    rm(joinpath(path, "C3"), recursive = true)
end

@testset "Save categories with multiplicity" begin 
    save_fusion_category(D, path, "D")

    D_ = load_fusion_category(joinpath(path, "D"))

    @test randomized_pentagon_axiom(D_,3)

    rm(joinpath(path, "D"), recursive = true)
end

#=----------------------------------------------------------
    Test numeric saving
----------------------------------------------------------=#

@testset "Save numeric multiplicity free categories" begin 
    numeric_symbols_to_csv(joinpath(path, "C1_numeric.csv"), numeric_F_symbols(C1))
    numeric_symbols_to_csv( joinpath(path, "C2_numeric.csv"), numeric_F_symbols(C2))
    numeric_symbols_to_csv(joinpath(path, "C3_numeric.csv"), numeric_F_symbols(C3))

    C1_ = load_numeric_fusion_category(joinpath(path, "C1_numeric.csv"))
    C2_ = load_numeric_fusion_category(joinpath(path, "C2_numeric.csv"))
    C3_ = load_numeric_fusion_category(joinpath(path, "C3_numeric.csv"))

    @test randomized_pentagon_axiom(C1_,3)
    @test randomized_pentagon_axiom(C2_,3)
    @test randomized_pentagon_axiom(C3_,3)
end


@testset "Save numeric categories with multiplicity" begin 
    numeric_symbols_to_csv(joinpath(path, "D_numeric.csv"), numeric_F_symbols(D, precision = 128))

    D_ = load_numeric_fusion_category(joinpath(path, "D_numeric.csv"))
    @test randomized_pentagon_axiom(D_,3)
end


end