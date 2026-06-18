#=----------------------------------------------------------
    Compute the centers of all multiplicity free unitary fusion 
    fusion categories up to rank 5 numerically
----------------------------------------------------------=#

using TensorCategories

# Specify the directory to store the centers
dir = mktempdir(cleanup = true) 

# Create the log file for the runtime 
log = open(joinpath(dir, "Centers_of_anyon_wiki.log"), "w")
write(log, "Code, simples, skeletonizing, saving\n")
flush(log)

# Numeric Computations at the moment only make sense for unitary categories
codes = anyonwiki_keys(5, "unitary")

print("\x1b[2J\x1b[H")
println("Computing the centers of all multiplicity free unitary fusion categories up to rank 5 numerically\n\n")

for (i,cat) in pairs(codes) 
    # load the category

    C = numeric(anyonwiki(cat...), 512)

    Z = center(C)

    # Compute the simples
    t1 = @elapsed simples(Z)

    # Skeletonization
    t2 = @elapsed Z2 = skeletonize(Z)

    # saving
    t3 = @elapsed numeric_symbols_to_csv("center_$(cat[1])_$(cat[2])_$(cat[3])_$(cat[4])_$(cat[5])", F_symbols(Z2))


    # loading 
    t4 = @elapsed Z3 = load_numeric_fusion_category("center_$(cat[1])_$(cat[2])_$(cat[3])_$(cat[4])_$(cat[5])", AcbField(32))

    # print progress
    i > 1 && print("\x1b[1A\x1b[2K"^7)
    print(cat)
    print(" - Progress: $(i)/$(length(codes))")
    println(": ")
    println("Simples computed in $t1 seconds")
    println("Skeletonized in $t2 seconds")
    println("Quick pentagon check $(randomized_pentagon_axiom(Z2, 3) ? "passed" : "failed")")
    println("Saved in $t3 seconds")
    println("Loaded in $t4 seconds")
    println("Quick check of loaded category $(randomized_pentagon_axiom(Z3, 3) ? "passed" : "failed")")


    # Write to log file
    write(log, string(cat))
    write(log, " - Progress: $(i)/$(length(codes))")
    write(log, ": \n")
    write(log, "Simples computed in $t1 seconds\n")
    write(log, "Skeletonized in $t2 seconds\n")
    write(log, "Quick pentagon check $(randomized_pentagon_axiom(Z2, 3) ? "passed" : "failed")\n")
    write(log, "Saved in $t3 seconds\n")
    write(log, "Loaded in $t4 seconds\n")
    write(log, "Quick check of loaded category $(randomized_pentagon_axiom(Z3, 3) ? "passed" : "failed")\n\n")
    flush(log)
end

close(log)

