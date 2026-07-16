# Utilities for logging large-scale computations in a reproducible way.
#
# These helpers provide a standardized CSV format recording computation
# results together with provenance information (timestamps, software
# versions, machine information, etc.). They are intended for batch and
# cluster jobs, where many independent tasks append their results to a
# common log file in a thread- and process-safe manner.
#
# Concurrent writes are synchronized using POSIX file locking (`flock(2)`),
# allowing multiple Julia processes on Linux systems to safely append to the
# same CSV file without corrupting it. This assumes that the underlying
# filesystem supports POSIX file locks.
#
# Created with the help of ChatGPT by UT
module ComputationLogging

using Dates
using Sockets

export append_csv_row,
       parse_task_number,
       pkgversion_string,
       standard_metadata,
       timestamp_string

# Constants for the POSIX `flock(2)` system call:
# exclusive lock and unlock, respectively.
const LOCK_EX = 2
const LOCK_UN = 8

"""
    parse_task_number([args = ARGS]) -> Int

Parse the required positive task number from the first command-line argument.
"""
function parse_task_number(args = ARGS)
    length(args) == 1 || throw(ArgumentError(
        "Expected exactly one argument: the positive task number."
    ))

    argument = only(args)
    task_number = tryparse(Int, argument)

    isnothing(task_number) && throw(ArgumentError(
        "Task number must be an integer, got $(repr(argument))."
    ))
    task_number > 0 || throw(ArgumentError(
        "Task number must be positive, got $task_number."
    ))

    return task_number
end

"""
    pkgversion_string(M::Module) -> String

Return the package version of `M`, or `"unknown"` if it cannot be determined.
"""
function pkgversion_string(M::Module)
    try
        version = Base.pkgversion(M)
        return isnothing(version) ? "unknown" : string(version)
    catch
        return "unknown"
    end
end

function cpu_string()
    try
        info = Sys.cpu_info()
        return isempty(info) ? "unknown" : info[1].model
    catch
        return "unknown"
    end
end

timestamp_string(t = now()) =
    Dates.format(t, dateformat"yyyy-mm-dd HH:MM:SS")

"""
    standard_metadata(; task_number, tensorcategories_version, oscar_version)

Return standard per-row provenance metadata.
"""
function standard_metadata(;
    task_number::Integer,
    tensorcategories_version,
    oscar_version,
)
    return (
        task_number = task_number,
        timestamp = timestamp_string(),
        hostname = gethostname(),
        pid = getpid(),
        cpu = cpu_string(),
        julia_version = string(VERSION),
        julia_threads = Threads.nthreads(),
        tensorcategories_version = string(tensorcategories_version),
        oscar_version = string(oscar_version),
        slurm_job_id = get(ENV, "SLURM_JOB_ID", "N/A"),
        slurm_array_task_id = get(ENV, "SLURM_ARRAY_TASK_ID", "N/A"),
    )
end

function csv_escape(x)
    s = string(x)
    return "\"" * replace(s, "\"" => "\"\"") * "\""
end

csv_row(xs...) = join(csv_escape.(xs), ",")

function with_file_lock(f::Function, lockfile::AbstractString)
    open(lockfile, "w") do lock_io
        result = ccall(:flock, Cint, (Cint, Cint), fd(lock_io), LOCK_EX)
        result == 0 || error("Could not acquire lock $lockfile")

        try
            return f()
        finally
            unlock_result =
                ccall(:flock, Cint, (Cint, Cint), fd(lock_io), LOCK_UN)
            unlock_result == 0 || @warn "Could not release lock $lockfile"
        end
    end
end

"""
    append_csv_row(outfile, columns, row)

Append one `NamedTuple` row to `outfile`.

The header is written exactly once. An adjacent `.lock` file and the POSIX
`flock(2)` system call serialize writes from separate Julia processes.
The computation itself should be performed before calling this function.
"""
function append_csv_row(
    outfile::AbstractString,
    columns::Tuple,
    row::NamedTuple,
)
    keys(row) == columns || error(
        "CSV schema mismatch.\nExpected: $columns\nGot:      $(keys(row))"
    )

    directory = dirname(outfile)
    isempty(directory) || mkpath(directory)

    lockfile = outfile * ".lock"

    with_file_lock(lockfile) do
        write_header = !isfile(outfile) || filesize(outfile) == 0

        open(outfile, "a") do io
            write_header && println(io, csv_row(columns...))
            println(io, csv_row(values(row)...))
            flush(io)
        end
    end

    return nothing
end

end
