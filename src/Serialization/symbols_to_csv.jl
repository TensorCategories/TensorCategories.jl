#=----------------------------------------------------------
    Save F- and R-symbols as a readable csv file
----------------------------------------------------------=#

"""
    numeric_symbols_to_csv(destination, symbols; delimiter=", ", convention=:column_major_packing)

Write a numerical F- or R-symbol dictionary. `convention` declares its existing
encoding; it does not convert the supplied plain dictionary. Obtain it with the
same keyword on `numeric_F_symbols` or `numeric_R_symbols`. Default output keeps
the historical headerless CSV format. Nondefault output includes a convention
header, which `load_numeric_fusion_category` reads automatically.
"""
function numeric_symbols_to_csv(destination::String, F::Dict{Vector{Int}, AcbFieldElem}; delimiter = ", ", convention::Symbol=:column_major_packing)
    _check_symbol_convention(convention)
    open(destination, "w") do io
        if convention != :column_major_packing
            write(io, "# TensorCategories symbol_format_version=1 symbol_convention=$convention\n")
        end
        # CSV rows are ordered by symbol indices, independently of Dict order.
        sorted = sort!(collect(F); by = first)

        for (k,v) ∈ sorted 
            m = max(accuracy_bits(v),0)
            if m in [typemax(Int), 0]
                m = 64
            end

            real_str = overlaps(real(v), zero(parent(real(v)))) ? "0.0" : string(BigFloat(BigFloat(real(v)); precision = m))
            imag_str = overlaps(imag(v), zero(parent(imag(v)))) ? "0.0" : string(BigFloat(BigFloat(imag(v)); precision = m))
            s = join([string.(k); [real_str, imag_str]], delimiter) * "\n"
            write(io, s)
        end
    end
end

"""
    numeric_symbols_from_csv(file, K=AcbField(64); delimiter=", ", convention=nothing)

Read a plain dictionary without changing its encoding. `convention` optionally
checks a file header or declares the encoding of headerless data (historically
`:column_major_packing`). The returned dictionary carries no convention tag.
"""
function numeric_symbols_from_csv(file::String, K::Field=AcbField(64);
        delimiter=", ", convention::Union{Nothing,Symbol}=nothing)
    first(_read_numeric_symbols(file,K; delimiter,convention))
end

function _read_numeric_symbols(file, K; delimiter, convention)
    F = Dict{Vector{Int},elem_type(K)}()
    lines = readlines(file)
    meta = Dict{String,Any}()
    if !isempty(lines) && startswith(first(lines), "# TensorCategories ")
        header = popfirst!(lines)
        m = match(r"^# TensorCategories symbol_format_version=(\d+) symbol_convention=(\w+)$",header)
        m === nothing && throw(ArgumentError("invalid symbol convention header"))
        meta["symbol_format_version"] = parse(Int,m[1])
        meta["symbol_convention"] = Symbol(m[2])
    end
    selected = _symbol_file_convention(meta,convention)
    for line in lines
        chunks = split(line,delimiter)
        index = parse.(Int,chunks[1:end-2])
        re,impart = K.(chunks[end-1:end])
        F[index] = re + impart*K(im)
    end
    F,selected
end

# Recover binary multiplicities from the COMPLETE admissible fusion-path
# labels, including zero matrix entries. Unlike a unit slice, this is invariant
# under relabeling. EGNO §§4.6,4.9: the two bases of Hom((ab)c,d) are indexed
# by intermediate simples and bases in their binary multiplicity spaces.
function _fusion_rules_from_symbol_dictionary(F::Dict; check::Bool=false, convention::Symbol=:column_major_packing)
    _check_symbol_convention(convention)
    isempty(F) && throw(ArgumentError("an F-symbol dictionary must be nonempty"))
    width = length(first(keys(F)))
    width in (6,10) || throw(ArgumentError("F-symbol labels must have length 6 or 10"))
    !check || all(k -> length(k) == width && all(>(0),k),keys(F)) ||
        throw(ArgumentError("inconsistent or nonpositive F-symbol indices"))
    n = maximum(maximum(k[1:4]) for k in keys(F))
    N = zeros(Int,n,n,n)
    counts = Dict{NTuple{4,Int},Int}()
    for key in keys(F)
        a,b,c,d = key[1:4]
        labels = (a,b,c,d)
        check && (counts[labels] = get(counts,labels,0)+1)
        if convention == :bonderson
            e,f = key[5],key[width == 6 ? 6 : 8]
            j,i,i2,j2 = width == 6 ? (1,1,1,1) : (key[6],key[7],key[9],key[10])
        else
            f,e = key[5],key[width == 6 ? 6 : 8]
            j,i,i2,j2 = width == 6 ? (1,1,1,1) : (key[9],key[10],key[7],key[6])
        end
        max(e,f) <= n || throw(ArgumentError("fusion-channel label outside the object range"))
        for (x,y,z,m) in ((a,b,e,j),(e,c,d,i),(b,c,f,i2),(a,f,d,j2))
            N[x,y,z] = max(N[x,y,z],m)
        end
    end
    N,counts
end

function _load_numeric_fusion_category(F::Dict, R, K; transpose=false,
        unit=nothing, pivotal=nothing, check::Bool=false, convention::Symbol=:column_major_packing)
    N,counts = _fusion_rules_from_symbol_dictionary(F;check,convention)
    n = size(N,1)
    identity = [Int(i == j) for i in 1:n,j in 1:n]
    units = [u for u in 1:n if N[u,:,:] == identity && N[:,u,:] == identity]
    length(units) == 1 || throw(ArgumentError("F-symbols must specify a unique simple tensor unit"))
    u = only(units)
    unit === nothing || unit == u || throw(ArgumentError("specified unit disagrees with the fusion paths"))
    ass = dict_to_associator(n,K,F; convention)
    if check
        for a in 1:n,b in 1:n,c in 1:n,d in 1:n
            rows = sum(N[a,b,e]*N[e,c,d] for e in 1:n)
            cols = sum(N[b,c,f]*N[a,f,d] for f in 1:n)
            get(counts,(a,b,c,d),0) == rows*cols ||
                throw(ArgumentError("incomplete F-symbol dictionary (including zero entries)"))
            rows == cols && size(ass[a,b,c,d]) == (rows,cols) ||
                throw(ArgumentError("F-symbol dimensions do not match the reconstructed fusion rules"))
        end
    end
    C = six_j_category(K,N)
    set_associator!(C,transpose ? Oscar.transpose.(ass) : ass)
    set_one!(C,u;check)
    if R !== nothing
        braid = dict_to_braiding(n,K,R; convention)
        if check
            for i in 1:n,j in 1:n,k in 1:n
                size(braid[i,j,k]) == (N[i,j,k],N[j,i,k]) ||
                    throw(ArgumentError("R-symbol dimensions disagree with the fusion rules"))
            end
        end
        set_braiding!(C,transpose ? Oscar.transpose.(braid) : braid)
    end
    # F/R data do not choose a pivotal structure. In particular Yang--Lee
    # must NOT be changed into the positive Fibonacci dimension character.
    if pivotal !== nothing
        length(pivotal) == n || throw(ArgumentError("one pivotal component per simple is required"))
        p = K.(pivotal)
        all(x -> !iszero(x),p) || throw(ArgumentError("pivotal components must be nonzero"))
        set_pivotal!(C,p)  # supplied numerical data, explicitly not certified
    end
    C
end

"""
    load_numeric_fusion_category(F::String, [K::AcbField]; unit=nothing, pivotal=nothing, delimiter=", ", transpose=false)
    load_numeric_fusion_category(F::String, R::String, [K::AcbField]; kwargs...)

Load complete F (and optional R) dictionaries, preserving their simple labels.
Fusion paths determine the unit; `unit` optionally checks its index. F/R data do not specify pivotal
maps: supply `pivotal` explicitly, or retain the constructor's unchecked all-one
components. No canonical spherical structure or exact coherence is asserted.
Pass `check=true` to validate completeness (including stored zero entries) and
structural block dimensions; supplied dictionaries are trusted by default.

`convention=nothing` uses the CSV header, with `:column_major_packing` as the
fallback for historical headerless files. An explicit convention declares the
encoding of headerless input and must agree with any header. F and R files must
use the same convention. `transpose=true` is the historical, separate operation
of transposing structural matrices *after* decoding; it is not a convention name.
"""
function load_numeric_fusion_category(F::String, K::AcbField=AcbField(64);
        delimiter=", ", transpose=false, unit=nothing, pivotal=nothing,
        check::Bool=false, convention::Union{Nothing,Symbol}=nothing)
    data,selected = _read_numeric_symbols(F,K;delimiter,convention)
    _load_numeric_fusion_category(data,nothing,K;transpose,unit,pivotal,check,convention=selected)
end

function load_numeric_fusion_category(F::String, R::String, K::AcbField=AcbField(64);
        delimiter=", ", transpose=false, unit=nothing, pivotal=nothing,
        check::Bool=false, convention::Union{Nothing,Symbol}=nothing)
    data,fc = _read_numeric_symbols(F,K;delimiter,convention)
    braid,rc = _read_numeric_symbols(R,K;delimiter,convention)
    fc == rc || throw(ArgumentError("F and R files use different symbol conventions"))
    _load_numeric_fusion_category(data,braid,K;transpose,unit,pivotal,check,convention=fc)
end

# Preserve the previous positional delimiter/transpose overloads.
load_numeric_fusion_category(F::String,R::String,K::AcbField,delimiter::String,transpose::Bool=false) =
    load_numeric_fusion_category(F,R,K;delimiter=delimiter,transpose=transpose)
