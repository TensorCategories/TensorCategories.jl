# Some extra tests
#
# Start with julia extra_tests2.jl
using TensorCategories
using Oscar
using ProgressMeter

#dir = "results/"
const dir = joinpath(pwd(), "output/extra_tests2/")
mkpath(dir)

codetostring(code) = join(string.(code),"_")

#codes = include("catcodes.jl")
codes = anyonwiki_keys(5)

@showprogress for code in codes
    try
        cat = anyonwiki(code...)
    catch e
        code[6] = 0
    end

    cs = codetostring(code)
    
    function sv(fn::String, obj)
        Oscar.save(dir * cs * "_" * fn * ".mrdi",obj)
    end

    cat = anyonwiki(code...)
    
    println("")
    println("===================================: ")
    print("Computing center for: ")
    println(cs)

    timings = Float64[]
    addtime!() = push!(timings, time())
    
    emb1 = cat.embedding
    
    sv("emb1", emb1); addtime!()
    
    println("> splitting center")
    Zcat, emb2 = split(center(cat)); addtime!()
    im_emb2 = emb2.image_data.prim_image
    sv("im_emb2", im_emb2); addtime!()

    println("> skeletonizing")
    sixjcat = six_j_category(Zcat); addtime!()

    println("> storing fusion ring")
    mt = multiplication_table(sixjcat); addtime!()
    sv("mt", mt) ; addtime!()

    println("> finding F-symbols")
    fs = F_symbols(sixjcat); addtime!()
    sv("fsymbols", fs); addtime!()

    println("> finding R-symbols")
    rs = R_symbols(sixjcat); addtime!()
    sv("rsymbols", rs); addtime!()

    println("> finding P-symbols")
    ps = P_symbols(sixjcat); addtime!()
    sv("psymbols", ps); addtime!()

    sv("timings", timings)
end