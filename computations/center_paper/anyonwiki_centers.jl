#=----------------------------------------------------------
    This script computes the centers of all 
    multiplicity-free fusion categories up to rank 5.

    WARNING: This will take a long time (multiple days) 
        to finish.

    It is recommended to start julia on multiple threads
    with julia --threads=N to speed up the computation.
----------------------------------------------------------=#

using TensorCategories, Oscar

# Specify the directory to store the centers
!isdir(joinpath(@__DIR__, "output")) && mkdir(joinpath(@__DIR__, "output"))
!isdir(joinpath(@__DIR__, "output/centers_of_anyonwiki")) && mkdir(joinpath(@__DIR__, "output/centers_of_anyonwiki"))
dir = joinpath(@__DIR__, "output", "centers_of_anyonwiki")

# Create the log file for the runtime 
log = open(joinpath(dir, "Centers_of_anyonwiki.log"), "w")
write(log, "Code, simples, splitting, skeletonizing, saving\n")
flush(log)

# The braidings and pivotal structures do not change the center
# so we can pick one representative
codes = unique(c -> c[1:5], anyonwiki_keys(5))

print("\x1b[2J\x1b[H")
println("Computing the centers of all multiplicity free unitary fusion categories up to rank 5 algebraically\n\n")

for (i,cat) in pairs(codes) 
    # load the category
    C = anyonwiki(cat...)

    Z = center(C)

    # Compute the simples
    t1 = @elapsed simples(Z)

    # compute the splitting
    t2 = @elapsed Z2 = split(Z)[1]

    # Skeletonize 
    t3 = @elapsed Z3 = six_j_category(Z2)

    # Store the results
    t4 = @elapsed save_fusion_category(Z3, dir, "center_$(cat[1])_$(cat[2])_$(cat[3])_$(cat[4])_$(cat[5])_$(cat[6])_$(cat[7])")

    # Print progress
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