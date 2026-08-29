#=----------------------------------------------------------
    Save F- and R-symbols as a readable csv file
----------------------------------------------------------=#

function numeric_symbols_to_csv(destination::String, F::Dict{Vector{Int}, AcbFieldElem}; delimiter = ", ")
    open(destination, "w") do io 
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

function numeric_symbols_from_csv(file::String, K::Field = AcbField(64); delimiter = ", ")
    F = Dict{Vector{Int}, elem_type(K)}()

    lines = readlines(file) 
    
    for l ∈ lines 
        chunks = split(l, delimiter)
        index = parse.(Int, chunks[1:end-2])

        real,imag = K.(chunks[end-1:end])

        push!(F, index => real + imag*K(im))
    end
    return F 
end

# Recover binary multiplicities from the COMPLETE admissible fusion-path
# labels, including zero matrix entries. Unlike a unit slice, this is invariant
# under relabeling. EGNO §§4.6,4.9: the two bases of Hom((ab)c,d) are indexed
# by intermediate simples and bases in their binary multiplicity spaces.
function _fusion_rules_from_symbol_dictionary(F::Dict)
    isempty(F) && throw(ArgumentError("an F-symbol dictionary must be nonempty"))
    width = length(first(keys(F)))
    width in (6,10) || throw(ArgumentError("F-symbol labels must have length 6 or 10"))
    all(k -> length(k) == width && all(>(0),k),keys(F)) ||
        throw(ArgumentError("inconsistent or nonpositive F-symbol indices"))
    n = maximum(maximum(k[1:4]) for k in keys(F))
    N = zeros(Int,n,n,n)
    counts = Dict{NTuple{4,Int},Int}()
    for key in keys(F)
        a,b,c,d = key[1:4]
        labels = (a,b,c,d)
        counts[labels] = get(counts,labels,0)+1
        f,e = key[5],key[width == 6 ? 6 : 8]
        max(e,f) <= n || throw(ArgumentError("fusion-channel label outside the object range"))
        # Ten-index convention: [a,b,c,d,f,j2,i2,e,j,i].
        j,i,i2,j2 = width == 6 ? (1,1,1,1) : (key[9],key[10],key[7],key[6])
        for (x,y,z,m) in ((a,b,e,j),(e,c,d,i),(b,c,f,i2),(a,f,d,j2))
            N[x,y,z] = max(N[x,y,z],m)
        end
    end
    N,counts
end

function _load_numeric_fusion_category(F::Dict, R, K; transpose=false, unit=nothing, pivotal=nothing)
    N,counts = _fusion_rules_from_symbol_dictionary(F)
    n = size(N,1)
    identity = [Int(i == j) for i in 1:n,j in 1:n]
    units = [u for u in 1:n if N[u,:,:] == identity && N[:,u,:] == identity]
    length(units) == 1 || throw(ArgumentError("F-symbols must specify a unique simple tensor unit"))
    u = only(units)
    unit === nothing || unit == u || throw(ArgumentError("specified unit disagrees with the fusion paths"))
    ass = dict_to_associator(n,K,F)
    for a in 1:n,b in 1:n,c in 1:n,d in 1:n
        rows = sum(N[a,b,e]*N[e,c,d] for e in 1:n)
        cols = sum(N[b,c,f]*N[a,f,d] for f in 1:n)
        # All dictionary indices are admissible by construction of N.
        # Their cardinality must equal the full Cartesian product of the
        # channel bases; this detects omitted zero entries/entire blocks
        # without enumerating six nested simple-label loops.
        get(counts,(a,b,c,d),0) == rows*cols ||
            throw(ArgumentError("incomplete F-symbol dictionary (including zero entries)"))
        rows == cols && size(ass[a,b,c,d]) == (rows,cols) ||
            throw(ArgumentError("F-symbol dimensions do not match the reconstructed fusion rules"))
    end
    C = six_j_category(K,N)
    set_associator!(C,transpose ? Oscar.transpose.(ass) : ass)
    set_one!(C,u)
    if R !== nothing
        braid = dict_to_braiding(n,K,R)
        for i in 1:n,j in 1:n,k in 1:n
            size(braid[i,j,k]) == (N[i,j,k],N[j,i,k]) ||
                throw(ArgumentError("R-symbol dimensions disagree with the fusion rules"))
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
Fusion paths determine the unit; `unit` optionally checks its index. All zero
entries in nonempty F blocks must be present. F/R data do not specify pivotal
maps: supply `pivotal` explicitly, or retain the constructor's unchecked all-one
components. No canonical spherical structure or exact coherence is asserted.
"""
function load_numeric_fusion_category(F::String, K::AcbField=AcbField(64);
        delimiter=", ", transpose=false, unit=nothing, pivotal=nothing)
    data = numeric_symbols_from_csv(F,K;delimiter=delimiter)
    _load_numeric_fusion_category(data,nothing,K;transpose=transpose,unit=unit,pivotal=pivotal)
end

function load_numeric_fusion_category(F::String, R::String, K::AcbField=AcbField(64);
        delimiter=", ", transpose=false, unit=nothing, pivotal=nothing)
    data = numeric_symbols_from_csv(F,K;delimiter=delimiter)
    braid = numeric_symbols_from_csv(R,K;delimiter=delimiter)
    _load_numeric_fusion_category(data,braid,K;transpose=transpose,unit=unit,pivotal=pivotal)
end

# Preserve the previous positional delimiter/transpose overloads.
load_numeric_fusion_category(F::String,R::String,K::AcbField,delimiter::String,transpose::Bool=false) =
    load_numeric_fusion_category(F,R,K;delimiter=delimiter,transpose=transpose)
