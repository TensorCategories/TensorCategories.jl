#=----------------------------------------------------------
    This script computes the centers of all 
    multiplicity-free fusion categories up to rank 5
    and stores the results in a directory.

    It is recommended to start julia on multiple threads
    with julia --threads=N to speed up the computation.
----------------------------------------------------------=#

using TensorCategories, Oscar, ProgressMeter 

# The path to store the results. Can be provided as a command line argument, otherwise the user will be prompted to enter one.
_dir = if isempty(ARGS) 
    println("Please specify a directory to store the results")
    readline()
else 
    ARGS[1]
end

dir = joinpath(_dir, "Centers/")
!isdir(dir) && mkdir(dir)

# Open the log file
log = open(joinpath(dir, "Centers.log"), "w")

# The codes of the anyonwiki 
codes = anyonwiki_keys(5)

# optional: The braidings and pivotal structures do not change the center
# so we can pick one representative
codes_without_braiding_and_pivotal = unique([c[1:5] for c ∈ codes])
codes = [codes[findfirst(e -> e[1:5] == c, codes)] for c ∈ codes_without_braiding_and_pivotal]

@showprogress for cat in codes 
    # load the category
    C = anyonwiki(cat...)

    # compute the center
    Z = center(C)
    t1 = @elapsed simples(Z)
    t2 = @elapsed Z2 = split(Z)[1]

    # Skeletonize 
    t3 = @elapsed Z3 = six_j_category(Z2)

    # Store the results
    t4 = @elapsed save_fusion_category(Z3, dir, "center_$(cat[1])_$(cat[2])_$(cat[3])_$(cat[4])_$(cat[5])")

    # Write to log file
    write(log, "[$(cat[1]),$(cat[2]),$(cat[3]),$(cat[4]),$(cat[5])],$t1,$t2,$t3,$t4\n")
    flush(log)
end

close(log)