# Checks the pentagon and hexagon (if braided) axioms of all AnyonWiki 
# fusion categories of rank <= 7.
#
# This uses the ComputationLogging module from computations/utils.
#
# The number of such categories is 973. Start computation with 
#
# julia anyonwiki_db_check.jl n 
#
# where n is the category number between 1 and 973.
using TensorCategories
using Oscar

include(joinpath(@__DIR__, "..", "utils", "computation_logging.jl"))
using .ComputationLogging

const FAIL_FAST = true

const OUTFILE = get(
    ENV,
    "TC_COMPUTATION_OUTFILE",
    joinpath(@__DIR__, "output", "anyonwiki_db_check.csv"),
)

codes = anyonwiki_keys(7)

task_number = parse_task_number()
task_number <= length(codes) || throw(ArgumentError(
    "Task number $task_number is out of range; expected 1:$(length(codes))."
))

cat = codes[task_number]

println("[$task_number / $(length(codes))] ", cat)

C = anyonwiki(cat...)

pentagon_runtime_seconds = @elapsed begin
    pentagon_axiom_result = pentagon_axiom(C)
end

if is_braided(C)
    hexagon_runtime_seconds = @elapsed begin
        hexagon_axiom_result = hexagon_axiom(C)
    end
else
    hexagon_axiom_result = "N/A"
    hexagon_runtime_seconds = "N/A"
end

metadata = standard_metadata(
    task_number = task_number,
    tensorcategories_version = TensorCategories._version_string(),
    oscar_version = pkgversion_string(Oscar),
)

columns = (
    :index,
    :code,
    :task_number,
    :timestamp,
    :hostname,
    :pid,
    :cpu,
    :julia_version,
    :julia_threads,
    :tensorcategories_version,
    :oscar_version,
    :slurm_job_id,
    :slurm_array_task_id,
    :pentagon_axiom,
    :pentagon_runtime_seconds,
    :hexagon_axiom,
    :hexagon_runtime_seconds,
    :peak_memory_gib
)

row = (
    index = task_number,
    code = repr(cat),
    metadata...,
    pentagon_axiom = pentagon_axiom_result,
    pentagon_runtime_seconds = pentagon_runtime_seconds,
    hexagon_axiom = hexagon_axiom_result,
    hexagon_runtime_seconds = hexagon_runtime_seconds,
    peak_memory_gib = round(Sys.maxrss() / 1024^3; digits=1)
)

append_csv_row(OUTFILE, columns, row)

println("Appended statistics to $OUTFILE")

if FAIL_FAST && (
    pentagon_axiom_result == false ||
    hexagon_axiom_result == false
)
    error("Axiom not satisfied for cat = $(repr(cat))")
end
