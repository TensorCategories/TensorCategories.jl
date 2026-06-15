#=----------------------------------------------------------
    This script computes the centers of all 
    multiplicity-free fusion categories up to rank 5.

    WARNING: This will take a long time (multiple days) 
        to finish.

    It is recommended to start julia on multiple threads
    with julia --threads=N to speed up the computation.
----------------------------------------------------------=#

using TensorCategories, Oscar, ProgressMeter 

# Specify the directory to store the centers
dir = mktempdir(cleanup = true) 

# Create the log file for the runtime 
log = open(joinpath(dir, "Centers_of_anyonwiki.log"), "w")
write(log, "Code, simples, splitting, skeletonizing, saving\n")
flush(log)

# The braidings and pivotal structures do not change the center
# so we can pick one representative
codes = unique(c -> c[1:5], anyonwiki_keys(5))


@showprogress for cat in codes 
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
    t4 = @elapsed save_fusion_category(Z3, dir, "center_$(cat[1])_$(cat[2])_$(cat[3])_$(cat[4])_$(cat[5])")

    # Write to log file
    write(log, "[$(cat[1]),$(cat[2]),$(cat[3]),$(cat[4]),$(cat[5]),$(cat[6]),$(cat[7])],$t1,$t2,$t3,$t4\n")
    flush(log)
end

close(log)