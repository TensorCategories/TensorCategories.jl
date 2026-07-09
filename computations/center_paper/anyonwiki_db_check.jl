using TensorCategories, Oscar
using Dates

const FAIL_FAST = true

codes = anyonwiki_keys(7)

run_timestamp = Dates.format(now(), dateformat"yyyy-mm-dd_HH-MM-SS")

!isdir(joinpath(@__DIR__, "output")) && mkdir(joinpath(@__DIR__, "output"))
!isdir(joinpath(@__DIR__, "output/anyonwiki_db_check")) && mkdir(joinpath(@__DIR__, "output/anyonwiki_db_check"))

const OUTFILE = "output/anyonwiki_db_check/anyonwiki_db_check_$(run_timestamp).csv"

function pkgversion_string(M::Module)
    try
        v = Base.pkgversion(M)
        return isnothing(v) ? "unknown" : string(v)
    catch
        return "unknown"
    end
end

function cpu_string()
    try
        return Sys.cpu_info()[1].model
    catch
        return "unknown"
    end
end

function csv_escape(x)
    s = string(x)
    return "\"" * replace(s, "\"" => "\"\"") * "\""
end

function csv_row(xs...)
    return join(csv_escape.(xs), ",")
end

cpu = cpu_string()
tc_version = TensorCategories._version_string()
oscar_version = pkgversion_string(Oscar)

open(OUTFILE, "w") do io
    println(io, csv_row(
        "index",
        "code",
        "timestamp",
        "cpu",
        "tensorcategories_version",
        "oscar_version",
        "pentagon_axiom",
        "pentagon_runtime_seconds",
        "hexagon_axiom",
        "hexagon_runtime_seconds",
    ))

    for (i, cat) in enumerate(codes)
        println("[$i / $(length(codes))] ", cat)

        C = anyonwiki(cat...)

        timestamp = Dates.format(now(), dateformat"yyyy-mm-dd HH:MM:SS")
        pentagon_runtime_seconds = @elapsed pentagon_axiom_result = pentagon_axiom(C)
        
        if is_braided(C)
            hexagon_runtime_seconds = @elapsed hexagon_axiom_result = hexagon_axiom(C)
        else
            hexagon_axiom_result = "N/A"
            hexagon_runtime_seconds = "N/A"
        end

        println(io, csv_row(
            i,
            repr(cat),
            timestamp,
            cpu,
            tc_version,
            oscar_version,
            pentagon_axiom_result,
            pentagon_runtime_seconds,
            hexagon_axiom_result,
            hexagon_runtime_seconds,
        ))
        flush(io)

        if FAIL_FAST && (pentagon_axiom_result == false || hexagon_runtime_seconds == false)
            error("Axiom not satisfied for cat = $(repr(cat))")
        end
    end
end

println("Wrote statistics to $(OUTFILE)")