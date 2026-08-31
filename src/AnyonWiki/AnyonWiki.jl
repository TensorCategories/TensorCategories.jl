#=----------------------------------------------------------
    Load fusion categories from the Anyon Wiki by 
    Gert Vercleyen. 
----------------------------------------------------------=#

associator_path = joinpath(@__DIR__, "AnyonWikiData//")
pivotal_path = joinpath(@__DIR__, "AnyonWikiData/PivotalStructures/")
anyon_path = joinpath(artifact"AnyonWiki", "AnyonWiki")




@doc raw""" 

    anyonwiki(r,m,n,i,a,b,p)

Load the fusion category from the list of multiplicity free fusion categories of rank ≤ 7 with index (r,m,n,i,a,b,p).
"""
function anyonwiki(rank::Int, 
                    multiplicity::Int, 
                    non_self_dual::Int,
                    fusion_ring::Int, 
                    associator::Int, 
                    braiding::Int, 
                    pivotal::Int)


    K,rt = load_anyonwiki_number_field(rank,multiplicity,non_self_dual,fusion_ring,associator,braiding, pivotal)

    cat_code = "$(rank)_$(multiplicity)_$(non_self_dual)_$(fusion_ring)_$(associator)_$(braiding)_$(pivotal)"
    cat_string = "cat_$cat_code.jl"

    C = six_j_category(K, ["𝟙"; String["X$i" for i in 2:rank]])

    ass = include(joinpath(anyon_path, "algebraic_F_symbols/$cat_string"))

    ass = Dict(k => K == QQ ? K(v...) : K(v) for (k,v) in ass)

    ass = dict_to_associator(rank, K, ass)

    set_tensor_product!(C, multiplication_table_from_F_symbols(ass))
    set_associator!(C, ass)
    set_one!(C, [i == 1 for i in 1:rank])

    if braiding != 0 
        braid = include(joinpath(anyon_path, "algebraic_R_symbols/$cat_string"))
        braid = Dict(k =>  K == QQ ? K(v...) : K(v) for (k,v) in braid)
        braid = dict_to_braiding(rank, K, braid)
        set_braiding!(C, braid)
    end

    piv = include(joinpath(anyon_path, "algebraic_P_symbols/$cat_string"))

    piv = Dict(k =>  K == QQ ? K(v...) : K(v) for (k,v) in piv)

    piv = [K(piv[[p]]) for p in 1:rank]
    set_pivotal!(C, piv)

    setfield!(C, :embedding, rt)
    set_name!(C, "Fusion Category $cat_code")
    return C
end

function anyonwiki(K::NumField, i,j,k,l,m,n,o)
    C = anyonwiki(i,j,k,l,m,n,o)
    _,emb = is_subfield(base_ring(C),K)
    extension_of_scalars(C, K, embedding = emb)
end

function anyonwiki(K::QQBarField, i,j,k,l,m,n,o)
    C = anyonwiki(i,j,k,l,m,n,o)
    extension_of_scalars(C, K)
end

function anyonwiki(K::AcbField, i,j,k,l,m,n,o)
    C = anyonwiki(i,j,k,l,m,n,o)
    numeric(C, precision(K))    
end

function anyonwiki(K::FqField,i,j,k,l,m,n,o)
    C = anyonwiki(i,j,k,l,m,n,o)
    extension_of_scalars(C,K)
end

function multiplication_table_from_F_symbols(ass::Array{<:MatElem,4}; unit=1)
    # Build multiplication_table
    N, = size(ass)

    mult = zeros(Int,N,N,N)
    
    weights = unit isa Integer ? [Int(i == unit) for i in 1:N] : unit
    length(weights) == N && all(>=(0),weights) && any(>(0),weights) ||
        throw(ArgumentError("invalid tensor-unit multiplicities"))
    for i ∈ 1:N, j ∈ 1:N, k ∈ 1:N
        mult[i,j,k] = sum(weights[u]*size(ass[u,i,j,k],1) for u in 1:N)
    end
    return mult
end

@doc raw""" 

    anyonwiki_center(i,j,k,l,m,n,o)

Return the center of the fusion category with index (i,j,k,l,m,n,o) from the database.
"""
function anyonwiki_center(i,j,k,l,m,n,o)
    path = anyonwiki_center_artifact_path(i,j,k,l,m,n,o)

    C = load_fusion_category(path)
    set_name!(C, replace(C.name, "Skeletization" => "Skeletonization"))
    C
end

function anyonwiki_center_artifact_path(i,j,k,l,m,n,o)
    try 
        if i ≤ 4 
            path = @artifact_str "AnyonWikiCenter1to4"
            path = joinpath(path, "center_$(i)_$(j)_$(k)_$(l)_$(m)_$(n)_$(o)")
            open(path)
            return path

        elseif i == 5 
            path = @artifact_str "AnyonWikiCenter5"
            path = joinpath(path, "center_$(i)_$(j)_$(k)_$(l)_$(m)_$(n)_$(o)")
            open(path)
            return path
        end
    catch 
        error("There is no center saved for a fusion category with index $((i,j,k,l,m,n,o))")
    end
end

function dict_to_associator(ass::Dict; convention::Symbol=:column_major_packing)
    isempty(ass) && throw(ArgumentError("an F-symbol dictionary must be nonempty"))
    # Every simple label appears among the four object indices, independently
    # of where the unit is listed or whether the first simple is invertible.
    N = maximum(maximum(k[1:4]) for k in keys(ass))
    dict_to_associator(N, parent(first(ass)[2]), ass; convention)
end

function dict_to_associator(N::Int, K::Field, ass::Dict; convention::Symbol=:column_major_packing)
    _check_symbol_convention(convention)
    # Transform associator dict to Matrices 

    ass_matrices = Array{MatElem,4}(undef,N,N,N,N)

    groups = group_dict_keys_by(e -> e[1:4], ass)

    for a ∈ 1:N, b ∈ 1:N, c ∈ 1:N, d ∈ 1:N 
        if !haskey(groups, [a,b,c,d])
            ass_matrices[a,b,c,d] = zero_matrix(K,0,0)
            continue
        end
        ass_matrices[a,b,c,d] = _F_symbol_matrix(K, groups[[a,b,c,d]], convention)
    end

    ass_matrices 
end

# Oscar's matrix(K,n,n,entries) reads rows, whereas the historical symbol
# dictionaries pack columns. Keep that decoding separate from fusion paths.
function _F_symbol_matrix(K, D, convention)
    ks = collect(keys(D))
    n = isqrt(length(ks))
    n^2 == length(ks) || throw(ArgumentError("incomplete square F-symbol block"))
    isempty(ks) && return zero_matrix(K,0,0)
    width = length(first(ks))
    width in (6,10) && all(k -> length(k) == width, ks) ||
        throw(ArgumentError("F-symbol labels must consistently have length 6 or 10"))
    if convention == :column_major_packing
        order = width == 6 ? [6,5] : [8,5,10,9,7,6]
        sort!(ks; by=k -> k[order])
        return transpose(matrix(K,n,n,[D[k] for k in ks]))
    end
    left(k) = width == 6 ? (k[5],1,1) : Tuple(k[5:7])
    right(k) = width == 6 ? (k[6],1,1) : Tuple(k[8:10])
    rows = sort!(unique(left.(ks)))
    cols = sort!(unique(right.(ks)))
    length(rows) == length(cols) == n ||
        throw(ArgumentError("incomplete Cartesian block of fusion paths"))
    ri = Dict(v => i for (i,v) in enumerate(rows))
    ci = Dict(v => i for (i,v) in enumerate(cols))
    A = zero_matrix(K,n,n)
    for k in ks
        A[ri[left(k)],ci[right(k)]] = D[k]
    end
    A
end

function _R_symbol_matrix(K, D, convention)
    ks = sort!(collect(keys(D)))
    n = isqrt(length(ks))
    n^2 == length(ks) || throw(ArgumentError("incomplete square R-symbol block"))
    isempty(ks) && return zero_matrix(K,0,0)
    width = length(first(ks))
    width in (3,5) && all(k -> length(k) == width, ks) ||
        throw(ArgumentError("R-symbol labels must consistently have length 3 or 5"))
    if width == 5
        [k[4:5] for k in ks] == [[i,j] for i in 1:n for j in 1:n] ||
            throw(ArgumentError("R-symbol basis indices must fill a square block starting at 1"))
    end
    A = matrix(K,n,n,[D[k] for k in ks])
    convention == :column_major_packing ? transpose(A) : A
end

# Version 1 adds an explicit convention; older, untagged archives retain the
# historical interpretation. Never infer a convention from matrix entries.
function _symbol_file_convention(meta, requested)
    requested === nothing || _check_symbol_convention(requested)
    tagged = haskey(meta, "symbol_format_version") || haskey(meta, "symbol_convention")
    if tagged
        get(meta, "symbol_format_version", nothing) == 1 ||
            throw(ArgumentError("unsupported symbol format version"))
        haskey(meta, "symbol_convention") || throw(ArgumentError("missing symbol convention"))
        stored = _check_symbol_convention(Symbol(meta["symbol_convention"]))
        requested === nothing || requested == stored ||
            throw(ArgumentError("requested convention conflicts with the file metadata"))
        return stored
    end
    requested === nothing ? :column_major_packing : requested
end

function anyonwiki_keys(n::Int = 7, attrs::String...)
    d = eval.(Meta.parse.(readlines(joinpath(@__DIR__, "keys.csv"))[2:end]))

    filter!(e -> e[1] <= n, d)

    "spherical" in attrs && filter!(e -> e[8], d)
    "modular" in attrs && filter!(e -> e[9], d)
    "unitary" in attrs && filter!(e -> e[10], d)
    return [k[1:7] for k in d]
end


function group_dict_keys_by(f::Function, D::Dict)
    groups = Dict()
    for (k,v) ∈ D 
        f_k = f(k)
        if f_k ∈ keys(groups)
            push!(groups[f_k], k => v)
        else 
            push!(groups, f_k => Dict(k => v))
        end
    end
    return groups 
end

function dict_to_braiding(ass::Dict; convention::Symbol=:column_major_packing)
    isempty(ass) && throw(ArgumentError("an R-symbol dictionary must be nonempty"))
    N = maximum(maximum(k[1:3]) for k in keys(ass))
    dict_to_braiding(N, parent(first(ass)[2]), ass; convention)
end

function dict_to_braiding(N::Int, K::Field, braid::Dict; convention::Symbol=:column_major_packing)
    _check_symbol_convention(convention)
    groups = group_dict_keys_by(k -> k[1:3], braid)
    braiding_array = Array{MatElem,3}(undef,N,N,N)
    for a in 1:N, b in 1:N, c in 1:N
        D = get(groups, [a,b,c], Dict())
        braiding_array[a,b,c] = _R_symbol_matrix(K,D,convention)
    end
    braiding_array
end



function load_anyonwiki_number_field(rank::Int, 
    multiplicity::Int, 
    non_self_dual::Int,
    fusion_ring::Int, 
    associator::Int, 
    braiding::Int, 
    pivotal::Int)

    field_dict = include(joinpath(@__DIR__, "base_field_generators.jl"))

    data = field_dict[[rank, multiplicity, non_self_dual, fusion_ring, associator, braiding, pivotal]]

    if typeof(data) == Int 
        if data == 0 
            return QQ, complex_embedding(rationals_as_number_field()[1], 1)
        end

        K,z = cyclotomic_field(data, "z$(data)")

        emb = complex_embeddings(K)[1]

        return K, emb
    else 
        p,str = data
        K,a = number_field(polynomial(QQ,p))
        
        CC = AcbField(2048)
        root = string_to_acb(CC,str)
        emb = complex_embedding(K,root)
        return K, emb
    end
end

function string_to_acb(CC::AcbField, str::String)
    re,co = split(str, "+")
    if co == "0"
        x = CC(re * "+/- 2e-510")
    else
        x = CC(re * "+/- 2e-510") + CC(co[1:end-2] * "+/- 2e-510")*CC(im)
    end
end


function finite_prime_field_with_root_of_unity(n::Int, lower_bound = 2)
    p = next_prime(maximum([n,lower_bound-1])) 
    while gcd(n, p - 1) < n
        p = next_prime(p)
    end
    return GF(p)
end


function fusion_ring_name(m::Array{Int,3})
    r = size(m,1)

    Iᵣ = [i == j ? 1 : 0 for i ∈ 1:r, j ∈ 1:r]

    # Group simples by One, self dual, and not self dual
    one = findfirst(i -> all([m[i,:,:] == m[:,i,:] == Iᵣ]), 1:r)
    self_dual = findall(i -> i != one && m[i,i,one] == 1, 1:r)
    non_self_dual = findall(i -> i != one && m[i,i,one] == 0, 1:r)
    
    n = length(non_self_dual)

    # Compute FPdims to sort groups
    fpdims = maximum.(filter(isreal, eigenvalues(QQBarField(), matrix(QQ, r,r, m[i,:,:]))) for i ∈ 1:r)


    #Compute dual pairs
    dual_pairs = Tuple.(unique(Set.(Tuple.(findall(==(1), m[:,:,1] .- Iᵣ)))))

    # First canonical ordering
    self_dual = sort(self_dual, by =  e -> fpdims[e])
    pairs = sort(dual_pairs, by = e -> fpdims[e[1]])
    non_self_dual = vcat(dual_pairs...)

    # get all permutations fixing the ordering rules 
    self_dual_perms = 
        if !isempty(self_dual)
            Sₘ = symmetric_group(length(self_dual))
            elements(stabilizer(Sₘ, fpdims[self_dual], permuted)[1])
        else 
            [symmetric_group(1)[0]]
        end
    
    pairs_perms = 
        if !isempty(dual_pairs) 
            Sₖ = symmetric_group(length(dual_pairs))
            elements(stabilizer(Sₖ, fpdims[getindex.(dual_pairs,1)], permuted)[1])
        else
            [symmetric_group(1)[0]]
        end

    # Create the signature for every permutation 
    signatures = []

    base = maximum(m) + 1
    
    fixed_order = [one; self_dual; vcat(collect.(dual_pairs)...)]

    for p1 ∈ self_dual_perms, p2 ∈ pairs_perms 
        
        binary_choice = Base.product([fpdims[i] == fpdims[j] ? [true,false] : [false] for (i,j) ∈ dual_pairs]...)

        # Add the permutations inside the pairs where possible
        perms = [[one; permuted(self_dual, p1); vcat([rev ? collect(reverse(v)) : collect(v) for (v,rev) ∈ zip(permuted(dual_pairs, p2), bool)]...)] for bool ∈ binary_choice]

        for p3 ∈ perms
            val = ""
            for i ∈ p3, j ∈ p3, k ∈ p3 
                val = val * "$(m[i,j,k])"
            end

            push!(signatures, parse(ZZRingElem, val, base))
        end
    end
    return r,n, maximum(signatures)
end

#=----------------------------------------------------------
    Save to anyonwiki 
----------------------------------------------------------=#

"""
    save_fusion_category(C::SixJCategory, path, name; convention=:column_major_packing)

Save exact F/R symbols in the chosen dictionary convention (see [`F_symbols`](@ref)
and [`R_symbols`](@ref)), together with the field, pivotal structure and category
metadata. New archives record format version 1 and the convention. Existing
archives are not changed. This is the symbol archive format, not Oscar's native
`save`/`load` serialization of structural matrices.
"""
function save_fusion_category(C::SixJCategory, path::String, name::String; convention::Symbol=:column_major_packing)
    _check_symbol_convention(convention)
    cat_path = joinpath(path, name)

    mkdir(cat_path)

    save_fusion_category_meta_data(C, joinpath(cat_path, "$(name)_meta"); convention)

    save_symbols(F_symbols(C; convention), joinpath(cat_path, "$(name)_F_symbols"), 4; convention)

    save_symbols(P_symbols(C), joinpath(cat_path, "$(name)_P_symbols"))
    
    if is_braided(C) 
        save_symbols(R_symbols(C; convention), joinpath(cat_path, "$(name)_R_symbols"); convention)
    end
    return nothing
end

function anyonwiki_center_meta(i,j,k,l,m,n,o)
    p = anyonwiki_center_artifact_path(i,j,k,l,m,n,o)
    name = splitpath(p)[end]

    meta = include(joinpath(p, "$(name)_meta"))
end

"""
    load_fusion_category(file; convention=nothing)

Load an exact symbol archive. By default use its recorded convention, or
`:column_major_packing` for an older archive without convention metadata.
An explicit convention declares the encoding of an untagged archive; it must
agree with any metadata present. See [`save_fusion_category`](@ref).
"""
function load_fusion_category(file::String; convention::Union{Nothing,Symbol}=nothing)
    
    name = splitpath(file)[end]

    meta = include(joinpath(file, "$(name)_meta"))

    convention = _symbol_file_convention(meta, convention)

    K = meta["field"]
    rank = meta["rank"]
    description = meta["name"]
    simples_names = meta["simples_names"]
    one = meta["one"]

    # include F/P/R-symbols as coefficient vectors, convert to number field elements and then to matrices
    F_symbols = load_F_symbols(rank,K,joinpath(file, "$(name)_F_symbols"); convention)

    P_symbols = include(joinpath(file, "$(name)_P_symbols"))
    P_symbols = [K == QQ ? K(P_symbols[k]...) : K(P_symbols[k]) for k ∈ sort(collect(keys(P_symbols)))]

    C = six_j_category(K, multiplication_table_from_F_symbols(F_symbols; unit=one))
    set_associator!(C, F_symbols)
    set_pivotal!(C, P_symbols)

    if haskey(meta, "embedding")
        r = meta["embedding"]
        if K == QQ
            setfield!(C, :embedding, complex_embedding(rationals_as_number_field()[1], r))
        else
            setfield!(C, :embedding, complex_embedding(K, r))
        end
    end
    
    if isfile(joinpath(file, "$(name)_R_symbols"))
        R_symbols = load_R_symbols(rank,K,joinpath(file, "$(name)_R_symbols"); convention)
        set_braiding!(C, R_symbols)
    end

    set_name!(C, description)
    set_simples_names!(C, simples_names)
    set_one!(C, one)

    C
end

function anyonwiki_center_multiplication_table(i,j,k,l,m,n,o)
    p = anyonwiki_center_artifact_path(i,j,k,l,m,n,o)
    name = splitpath(p)[end]

    meta = include(joinpath(p, "$(name)_meta"))

    rank = meta["rank"]
   
    p2 = joinpath(p, "$(name)_F_symbols")

    dir = filter(e -> e[1:3] == "[1,", readdir(p2))

    multiplicities = Dict(eval(Meta.parse(q))[2:4] => length(include(joinpath(p2,q))) for q in dir)

    [Int(sqrt(get(multiplicities, [i,j,k], 0))) for i in 1:rank, j in 1:rank, k in 1:rank]
end

function anyonwiki_center_grothendieck_ring(i,j,k,l,m,n,o)
    meta = anyonwiki_center_meta(i,j,k,l,m,n,o)
    names = meta["simples_names"]
    m = anyonwiki_center_multiplication_table(i,j,k,l,m,n,o)
    ℕRing(names, m, [1; zeros(Int, length(names)-1)])
end


"""
    load_F_symbols(rank, K, path; convention=:column_major_packing)

Decode a directory of exact coefficient dictionaries into associator matrices.
Unlike `load_fusion_category`, this low-level reader has no category metadata;
`convention` must describe the supplied dictionaries.
"""
function load_F_symbols(rank::Int, K::Field, path::String; convention::Symbol=:column_major_packing)
    _check_symbol_convention(convention)
    ass = Array{MatElem,4}(undef,rank,rank,rank,rank)
    for i in 1:rank, j in 1:rank, k in 1:rank, l in 1:rank
        file = joinpath(path, "[$i, $j, $k, $l]")
        if isfile(file)
            data = include(file)
            D = Dict(key => (K == QQ ? K(v...) : K(v)) for (key,v) in data)
            ass[i,j,k,l] = _F_symbol_matrix(K,D,convention)
        else
            ass[i,j,k,l] = zero_matrix(K,0,0)
        end
    end
    ass
end

"""
    load_R_symbols(rank, K, path; convention=:column_major_packing)

Decode an exact coefficient dictionary into braiding matrices. Supply the
encoding explicitly when reading nondefault data without category metadata.
"""
function load_R_symbols(rank::Int, K::Field, path::String; convention::Symbol=:column_major_packing)
    data = include(path)
    D = Dict(key => (K == QQ ? K(v...) : K(v)) for (key,v) in data)
    dict_to_braiding(rank,K,D; convention)
end



"""
    save_symbols(S::Dict, path, chunk=0; convention=:column_major_packing)

Write an already encoded dictionary as exact coefficient vectors. As for
`numeric_symbols_to_csv`, the keyword declares the supplied encoding and does
not convert it. Nondefault files carry a comment identifying the convention;
low-level readers still require it explicitly. Use `save_fusion_category` for
category metadata and automatic convention selection on loading.
"""
function save_symbols(S::Dict, path::String, chunk::Int = 0; convention::Symbol=:column_major_packing)
    _check_symbol_convention(convention)
    K = parent(first(S)[2])

    if chunk != 0
        chunks = group_dict_keys_by(e -> e[1:chunk], S)
        mkdir(path)

        for (k,ch) ∈ chunks
            open(joinpath(path, "$k"), "w") do io 
                convention == :column_major_packing || write(io,"# symbol_convention=$convention\n")
                write(io, "Dict(\n")
                
                if K == QQ
                    write(io, join(["\t$k => $([v])" for (k,v) ∈ ch], ",\n") )
                else
                    write(io, join(["\t$k => $(coefficients(v))" for (k,v) ∈ ch], ",\n"))
                end

                write(io, ")")
            end
        end
    else
        open(path, "w") do io 
            convention == :column_major_packing || write(io,"# symbol_convention=$convention\n")
            write(io, "Dict(\n")
            
            if K == QQ
                write(io, join(["\t$k => $([v])" for (k,v) ∈ S], ",\n") )
            else
                write(io, join(["\t$k => $(coefficients(v))" for (k,v) ∈ S], ",\n"))
            end

            write(io, ")")
        end
    end
end

function save_fusion_category_meta_data(C::SixJCategory, file::String; convention::Symbol=:column_major_packing)
    _check_symbol_convention(convention)
    open(file, "w") do io 
        write(io, "# Meta data for $C\n\n")
        write(io, """Dict(\n
        \t\"name\" => \"$(C.name)\",\n""")
        write(io, "\t\"symbol_format_version\" => 1,\n")
        write(io, "\t\"symbol_convention\" => :$convention,\n")
        if base_ring(C) == QQ 
            write(io, "\t\"field\" => QQ,\n")
        else
            write(io, "\t\"field\" => number_field(polynomial(QQ,$(collect(coefficients(base_ring(C).pol)))))[1],\n")
        end
        write(io, "
        \t\"rank\"=> $(rank(C)),\n
        \t\"multiplicity\" => $(multiplicity(C)),\n
        \t\"simples_names\" => $(simples_names(C)),\n
        \t\"one\" => $(C.one)
        ")

        if isdefined(C, :embedding)
            r = getfield(C, :embedding).r
            write(io, ",\n\t\"embedding\" => AcbField()(\"$(string(real(r)))\") + AcbField()(\"$(string(imag(r)))\")*AcbField()(im)\n")
        end
        write(io, ")")
    end
end


function anyonwiki_center_simple_name_to_vec(s::String, simpls::Vector{String})
    s = split(s, ",")[1]
    s = replace(s, "(" => "", "⊕" => "", ")" => "")

    ret = []

    for S ∈ simpls 
        if occursin(Regex("(\\d+)⋅$S"), s)
            m = collect(eachmatch(Regex("(\\d+)⋅$S"),s))[1]
            push!(ret, parse(Int, match(r"\d+", m.match).match))
        elseif occursin(S, s)
            push!(ret, 1)
        else
            push!(ret, 0)
        end
    end
    ret
end


function anyonwiki_center_forgetful(i,j,k,l,m,n,o)
    names = TensorCategories.anyonwiki_center_meta(i,j,k,l,m,n,o)["simples_names"]
    vecs = transpose(hcat([anyonwiki_center_simple_name_to_vec(s, ["𝟙"; ["X$q" for q ∈ 2:i]]) for s ∈ names]...))
end
