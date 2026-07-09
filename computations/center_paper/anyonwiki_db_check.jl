using TensorCategories, Oscar
using Dates

const FAIL_FAST = true

codes = anyonwiki_keys(5)

run_timestamp = Dates.format(now(), dateformat"yyyy-mm-dd_HH-MM-SS")
const OUTFILE = "output/anyonwiki_db_check_$(run_timestamp).csv"

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
    ))

    for (i, cat) in enumerate(codes)
        println("[$i / $(length(codes))] ", cat)

        C = anyonwiki(cat...)

        timestamp = Dates.format(now(), dateformat"yyyy-mm-dd HH:MM:SS")
        runtime = @elapsed result = pentagon_axiom(C)

        println(io, csv_row(
            i,
            repr(cat),
            timestamp,
            cpu,
            tc_version,
            oscar_version,
            result,
            runtime,
        ))
        flush(io)

        if FAIL_FAST && result == false
            error("Pentagon axiom not satisfied for cat = $(repr(cat))")
        end
    end
end

println("Wrote statistics to $(OUTFILE)")