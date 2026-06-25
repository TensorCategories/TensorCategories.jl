#=----------------------------------------------------------
    This script computes centers of multiplicity-free fusion
    categories from the AnyonWiki rank-5 list.

    Distributed version with named command line arguments.

    Usage:

        julia anyonwiki_centers_dist.jl \
            --workers 16 \
            --threads 1 \
            --first 1 \
            --last 78

    Examples:

        # All codes, 16 workers, 1 thread per worker
        julia anyonwiki_centers_dist.jl --workers 16 --threads 1

        # All codes, 1 worker, 16 Julia threads
        julia anyonwiki_centers_dist.jl --workers 1 --threads 16

        # Only global indices 25 through 40 in the deterministic filtered list
        julia anyonwiki_centers_dist.jl --workers 4 --threads 4 --first 25 --last 40

    Do not additionally start Julia with `-p`; this script creates
    the requested workers itself.

    Indices are 1-based and inclusive, as usual in Julia.

    This script was generated with the help of ChatGPT.
----------------------------------------------------------=#

using Distributed
using Dates
using Printf
using TensorCategories

Base.@kwdef struct ScriptOptions
    workers::Int = 1
    threads_per_worker::Int = 1
    first::Union{Nothing, Int} = nothing
    last::Union{Nothing, Int} = nothing
end

function usage()
    println("""
Usage:
    julia anyonwiki_centers_dist.jl [OPTIONS]

Options:
    --workers N, -w N
        Number of Julia worker processes to create. Default: 1.

    --threads N, -t N
        Number of Julia threads per worker process. Default: 1.

    --first N, -f N
        First global index in the filtered AnyonWiki list to compute.
        Indices are 1-based and inclusive. Default: 1.

    --last N, -l N
        Last global index in the filtered AnyonWiki list to compute.
        Indices are 1-based and inclusive. Default: length(codes).

    --help, -h
        Show this help text.

Examples:
    julia anyonwiki_centers_dist.jl --workers 16 --threads 1
    julia anyonwiki_centers_dist.jl --workers 1 --threads 16
    julia anyonwiki_centers_dist.jl --workers 4 --threads 4 --first 25 --last 40
""")
end

function parse_positive_int(s::AbstractString, flag::AbstractString)
    try
        x = parse(Int, s)
        x >= 1 || error()
        return x
    catch
        error("Option $flag expects a positive integer, got `$s`.")
    end
end

function set_option!(opts::Dict{String, String}, key::String, value::String)
    aliases = Dict(
        "threads-per-worker" => "threads",
        "from" => "first",
        "to" => "last",
    )

    key = get(aliases, key, key)
    allowed = Set(["workers", "threads", "first", "last"])

    if !(key in allowed)
        error("Unknown option `--$key`. Use --help for usage.")
    end

    if haskey(opts, key)
        error("Option `--$key` was given more than once.")
    end

    opts[key] = value
    return opts
end

function parse_cli(args)
    opts = Dict{String, String}()

    short_options = Dict(
        "-w" => "workers",
        "-t" => "threads",
        "-f" => "first",
        "-l" => "last",
    )

    i = 1
    while i <= length(args)
        a = args[i]

        if a == "--help" || a == "-h"
            usage()
            exit(0)

        elseif startswith(a, "--")
            raw = a[3:end]

            if occursin("=", raw)
                parts = split(raw, "="; limit = 2)
                key, value = parts[1], parts[2]
            else
                key = raw
                i < length(args) || error("Missing value for option `$a`. Use --help for usage.")
                i += 1
                value = args[i]
            end

            set_option!(opts, key, value)

        elseif haskey(short_options, a)
            i < length(args) || error("Missing value for option `$a`. Use --help for usage.")
            i += 1
            set_option!(opts, short_options[a], args[i])

        else
            error("Unexpected positional argument `$a`. Use named options, e.g. --workers 4 --threads 4 --first 25 --last 40.")
        end

        i += 1
    end

    return ScriptOptions(
        workers = haskey(opts, "workers") ? parse_positive_int(opts["workers"], "--workers") : 1,
        threads_per_worker = haskey(opts, "threads") ? parse_positive_int(opts["threads"], "--threads") : 1,
        first = haskey(opts, "first") ? parse_positive_int(opts["first"], "--first") : nothing,
        last = haskey(opts, "last") ? parse_positive_int(opts["last"], "--last") : nothing,
    )
end

const OPTIONS = parse_cli(ARGS)
const NUM_WORKERS = OPTIONS.workers
const THREADS_PER_WORKER = OPTIONS.threads_per_worker
const RUN_ROOT = joinpath(pwd(), "output/anyonwiki_centers_dist")
const CPU_TYPE = Sys.cpu_info()[1].model
const TIMING_HEADER = (
    "anyonwiki_code",
    "global_index",
    "datetime",
    "cpu_type",
    "workers",
    "threads",
    "simples_seconds",
    "splitting_seconds",
    "skeletonizing_seconds",
    "saving_seconds",
    "total_seconds",
    "check_split",
    "check_skeletonized",
)

function fresh_run_dir(first_index, last_index)
    mkpath(RUN_ROOT)

    stamp = Dates.format(now(), "yyyymmdd_HHMMSS")
    base = joinpath(
        RUN_ROOT,
        "centers_rank5_$(stamp)_w$(NUM_WORKERS)_t$(THREADS_PER_WORKER)_i$(first_index)-$(last_index)"
    )

    dir = base
    k = 1
    while ispath(dir)
        dir = "$(base)_$(k)"
        k += 1
    end

    mkpath(dir)
    return dir
end

function open_append_tsv(path, header)
    new_file = !isfile(path) || filesize(path) == 0
    io = open(path, "a")

    if new_file
        println(io, join(header, '\t'))
        flush(io)
    end

    return io
end

function log_line(io, s = "")
    println(io, s)
    flush(io)
end

function format_seconds(x)
    if isnan(x)
        return "NaN"
    end
    return @sprintf("%.1f", x)
end

println("Loaded TensorCategories on master process $(myid()).")
println("Master Julia threads: ", Threads.nthreads())
println("Adding $NUM_WORKERS worker(s), each with $THREADS_PER_WORKER Julia thread(s).")
flush(stdout)

addprocs(
    NUM_WORKERS;
    exeflags = `--project=$(Base.active_project()) --threads=$THREADS_PER_WORKER`
)

println("Master process: ", myid())
println("Number of workers: ", nworkers())
println("Worker ids: ", workers())
flush(stdout)

# Loading TensorCategories simultaneously with `@everywhere using TensorCategories`
# may stall on some systems. Load it sequentially on the workers instead.
for w in workers()
    println("Loading TensorCategories on worker $w")
    flush(stdout)

    msg = remotecall_fetch(w) do
        Core.eval(Main, :(using TensorCategories))
        "Loaded TensorCategories on worker $(myid()); threads=$(Threads.nthreads())"
    end

    println(msg)
    flush(stdout)
end

@everywhere function compute_center_job(global_index, cat, dir)
    try
        println("[worker $(myid())] START #$(global_index) $(cat)")
        flush(stdout)

        C = anyonwiki(cat...)
        Z = center(C)

        local Z2
        local Z3

        t_total = @elapsed begin

            t_simples = @elapsed simples(Z)
            t_split = @elapsed Z2 = split(Z)[1]
            t_skeletonize = @elapsed Z3 = six_j_category(Z2)

        end

        filename = "center_$(cat[1])_$(cat[2])_$(cat[3])_$(cat[4])_$(cat[5])"
        t_save = @elapsed save_fusion_category(Z3, dir, filename)

        check_split = randomized_pentagon_axiom(Z2, 3)
        check_skeletonized = randomized_pentagon_axiom(Z3, 3)

        

        println("[worker $(myid())] DONE  #$(global_index) $(cat)")
        flush(stdout)

        return (
            ok = true,
            global_index = global_index,
            cat = cat,
            worker = myid(),
            filename = filename,
            t_simples = t_simples,
            t_split = t_split,
            t_skeletonize = t_skeletonize,
            t_save = t_save,
            t_total = t_total,
            check_split = check_split,
            check_skeletonized = check_skeletonized,
            error = "",
        )
    catch err
        bt = catch_backtrace()
        msg = sprint() do io
            showerror(io, err, bt)
        end

        println("[worker $(myid())] ERROR #$(global_index) $(cat)")
        println(msg)
        flush(stdout)

        return (
            ok = false,
            global_index = global_index,
            cat = cat,
            worker = myid(),
            filename = "",
            t_simples = NaN,
            t_split = NaN,
            t_skeletonize = NaN,
            t_save = NaN,
            t_total = NaN,
            check_split = false,
            check_skeletonized = false,
            error = msg,
        )
    end
end

@everywhere function worker_loop!(jobs, results, dir)
    while true
        job = take!(jobs)
        job === nothing && break

        global_index, cat = job
        put!(results, compute_center_job(global_index, cat, dir))
    end

    return nothing
end

# The braidings and pivotal structures do not change the center,
# so we pick one representative.
#
# Sorting is intentional: if we allow index ranges, the list order must be
# deterministic across runs.
codes_all = sort!(
    collect(unique(c -> c[1:5], anyonwiki_keys(5)));
    by = c -> Tuple(c[1:5])
)

total_codes = length(codes_all)

first_index = OPTIONS.first === nothing ? 1 : OPTIONS.first
last_index = OPTIONS.last === nothing ? total_codes : OPTIONS.last

if first_index > total_codes
    error("--first=$first_index is larger than the number of filtered codes ($total_codes).")
end

if last_index > total_codes
    error("--last=$last_index is larger than the number of filtered codes ($total_codes).")
end

if first_index > last_index
    error("Invalid range: --first=$first_index is larger than --last=$last_index.")
end

selected_codes = codes_all[first_index:last_index]
job_items = collect(zip(first_index:last_index, selected_codes))
njobs = length(job_items)

# Use a fresh output directory for every run, so neither saved categories nor logs
# overwrite previous computations.
dir = fresh_run_dir(first_index, last_index)
run_id = basename(dir)
started_at = now()

human_log_path = joinpath(dir, "Centers_of_anyonwiki.log")
timing_log_path = joinpath(dir, "timings.tsv")
global_timing_log_path = joinpath(RUN_ROOT, "timings_all.tsv")

human_log = open(human_log_path, "w")
timing_log = open(timing_log_path, "w")
global_timing_log = open_append_tsv(global_timing_log_path, TIMING_HEADER)

println(timing_log, join(TIMING_HEADER, '\t'))
flush(timing_log)

log_line(human_log, "Computing selected centers of multiplicity-free unitary fusion categories of rank 5 algebraically")
log_line(human_log, "Run started: $(started_at)")
log_line(human_log, "Run id: $run_id")
log_line(human_log, "Workers: $NUM_WORKERS")
log_line(human_log, "Threads per worker: $THREADS_PER_WORKER")
log_line(human_log, "Output directory: $dir")
log_line(human_log, "Total filtered codes: $total_codes")
log_line(human_log, "Selected range: $first_index:$last_index")
log_line(human_log, "Number of selected jobs: $njobs")
log_line(human_log, "Per-run timing log: $timing_log_path")
log_line(human_log, "Append-only global timing log: $global_timing_log_path")
log_line(human_log)

println()
println("Computing selected centers of multiplicity-free unitary fusion categories of rank 5 algebraically")
println("Workers:                 $NUM_WORKERS")
println("Threads per worker:      $THREADS_PER_WORKER")
println("Total filtered codes:    $total_codes")
println("Selected range:          $first_index:$last_index")
println("Number of selected jobs: $njobs")
println("Output directory:        $dir")
println("Human log:               $human_log_path")
println("Timing log:              $timing_log_path")
println("Global timing log:       $global_timing_log_path")
println()
flush(stdout)

jobs = RemoteChannel(() -> Channel{Any}(njobs + NUM_WORKERS), 1)
results = RemoteChannel(() -> Channel{Any}(njobs), 1)

for job in job_items
    put!(jobs, job)
end
for _ in workers()
    put!(jobs, nothing)
end

completed = Ref(0)
failed = Ref(0)

@sync begin
    for w in workers()
        @async remotecall_wait(worker_loop!, w, jobs, results, dir)
    end

    @async begin
        for _ in 1:njobs
            result = take!(results)
            completed[] += 1
            completion_index = completed[]

            if result.ok
                println("[$completion_index/$njobs, global $(result.global_index)/$total_codes] Finished $(result.cat) on worker $(result.worker)")
                println("  Simples computed in       $(format_seconds(result.t_simples)) seconds")
                println("  Split in                  $(format_seconds(result.t_split)) seconds")
                println("  Skeletonized in           $(format_seconds(result.t_skeletonize)) seconds")
                println("  Saved in                  $(format_seconds(result.t_save)) seconds")
                println("  Quick pentagon check split:        $(result.check_split ? "passed" : "failed")")
                println("  Quick pentagon check skeletonized: $(result.check_skeletonized ? "passed" : "failed")")
                println("  File: $(result.filename)")
                println()
                flush(stdout)

                log_line(human_log, "[$completion_index/$njobs, global $(result.global_index)/$total_codes] $(result.cat) on worker $(result.worker)")
                log_line(human_log, "Simples computed in $(format_seconds(result.t_simples)) seconds")
                log_line(human_log, "Split in $(format_seconds(result.t_split)) seconds")
                log_line(human_log, "Skeletonized in $(format_seconds(result.t_skeletonize)) seconds")
                log_line(human_log, "Saved in $(format_seconds(result.t_save)) seconds")
                log_line(human_log, "Quick pentagon check split: $(result.check_split ? "passed" : "failed")")
                log_line(human_log, "Quick pentagon check skeletonized: $(result.check_skeletonized ? "passed" : "failed")")
                log_line(human_log, "File: $(result.filename)")
                log_line(human_log)

                status = "ok"
            else
                failed[] += 1

                println("[$completion_index/$njobs, global $(result.global_index)/$total_codes] FAILED $(result.cat) on worker $(result.worker)")
                println(result.error)
                println()
                flush(stdout)

                log_line(human_log, "[$completion_index/$njobs, global $(result.global_index)/$total_codes] FAILED $(result.cat) on worker $(result.worker)")
                log_line(human_log, result.error)
                log_line(human_log)

                status = "failed"
            end

            timing_line = join((
                string(result.cat),
                string(result.global_index),
                string(now()),
                CPU_TYPE,
                string(NUM_WORKERS),
                string(THREADS_PER_WORKER),
                format_seconds(result.t_simples),
                format_seconds(result.t_split),
                format_seconds(result.t_skeletonize),
                format_seconds(result.t_save),
                format_seconds(result.t_total),
                string(result.check_split),
                string(result.check_skeletonized),
            ), '\t')

            println(timing_log, timing_line)
            flush(timing_log)

            println(global_timing_log, timing_line)
            flush(global_timing_log)
        end
    end
end

log_line(human_log, "Run finished: $(now())")
log_line(human_log, "Successful jobs: $(njobs - failed[])")
log_line(human_log, "Failed jobs: $(failed[])")

close(human_log)
close(timing_log)
close(global_timing_log)

println("Done.")
println("Successful jobs:    ", njobs - failed[])
println("Failed jobs:        ", failed[])
println("Output directory:   ", dir)
println("Human log:          ", human_log_path)
println("Timing log:         ", timing_log_path)
println("Global timing log:  ", global_timing_log_path)
flush(stdout)
