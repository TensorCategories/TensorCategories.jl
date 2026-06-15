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

# The braidings and pivotal structures do not change the center
# so we can pick one representative
codes = anyonwiki_keys(5, "unitary")


for cat in codes 
    # load the category
    print(cat)
    print(": ")

    C = numeric(anyonwiki(cat...), 512)

    Z = center(C)

    # Compute the simples
    t1 = @elapsed simples(Z)
    print("simples computed in $t1 seconds")

    # Skeletonization
    t2 = @elapsed Z2 = skeletonize(Z)
    print(", skeletonized in $t2 seconds")
    println(", quick pentagon ckeck $(randomized_pentagon_axiom(Z2, 3) ? "passed" : "failed")")

    # Write to log file
    write(log, "[$(cat[1]),$(cat[2]),$(cat[3]),$(cat[4]),$(cat[5])],$t1,$t2\n")
    flush(log)
end

close(log)

