function same_matrices(C,D; numerical=false)
    N = multiplication_table(C)
    @test multiplication_table(D) == N
    for I in CartesianIndices(C.ass)
        A,B = TC.six_j_symbol(C,Tuple(I)...),TC.six_j_symbol(D,Tuple(I)...)
        @test size(A) == size(B)
        if numerical
            @test all(overlaps(A[i,j],B[i,j]) for i in 1:nrows(A),j in 1:ncols(A))
        else
            @test A == B
        end
    end
    for I in CartesianIndices(C.braiding)
        A,B = TC.r_symbol(C,Tuple(I)...),TC.r_symbol(D,Tuple(I)...)
        @test size(A) == size(B)
        if numerical
            @test all(overlaps(A[i,j],B[i,j]) for i in 1:nrows(A),j in 1:ncols(A))
        else
            @test A == B
        end
    end
end

@testset "F/R symbol files and numerical conventions" begin
    for C in (anyonwiki(3,1,0,1,1,1,1),pointed_fixture())
        K = base_ring(C)
        emb = K == QQ ? complex_embedding(rationals_as_number_field()[1],1) : getfield(C,:embedding)
        setfield!(C,:embedding,emb)
        for convention in (:column_major_packing,:bonderson)
            F = F_symbols(C;convention)
            R = R_symbols(C;convention)
            Fn = numeric_F_symbols(C;convention,precision=128)
            Rn = numeric_R_symbols(C;convention,precision=128)
            @test keys(Fn) == keys(F) && keys(Rn) == keys(R)
            @test all(overlaps(v,emb(K == QQ ? number_field(emb)(F[k]) : F[k],128)) for (k,v) in Fn)
            @test all(overlaps(v,emb(K == QQ ? number_field(emb)(R[k]) : R[k],128)) for (k,v) in Rn)
            Fn_explicit = numeric_F_symbols(C,emb;convention,precision=128)
            Rn_explicit = numeric_R_symbols(C,emb;convention,precision=128)
            @test all(overlaps(v,Fn_explicit[k]) for (k,v) in Fn)
            @test all(overlaps(v,Rn_explicit[k]) for (k,v) in Rn)
            mktempdir() do dir
                save_fusion_category(C,dir,"category";convention)
                path = joinpath(dir,"category")
                meta_file = joinpath(path,"category_meta")
                metadata = include(meta_file)
                @test metadata["symbol_convention"] == convention
                @test metadata["symbol_format_version"] == 1
                D = load_fusion_category(path)
                # Reconstruct exact field elements in C's field, independently
                # of the number-field parent newly constructed by the loader.
                DF = F_symbols(D;convention=:bonderson)
                DR = R_symbols(D;convention=:bonderson)
                coerce(v) = K == QQ ? K(v) : K(collect(coefficients(v)))
                @test Dict(k=>coerce(v) for (k,v) in DF) == F_symbols(C;convention=:bonderson)
                @test Dict(k=>coerce(v) for (k,v) in DR) == R_symbols(C;convention=:bonderson)
                @test D.one == C.one && simples_names(D) == simples_names(C)
                @test coerce.(D.pivotal) == C.pivotal
                other = convention == :bonderson ? :column_major_packing : :bonderson
                @test_throws ArgumentError load_fusion_category(path;convention=other)
                @test_throws ArgumentError load_fusion_category(path;convention=:unknown)
                text = read(meta_file,String)
                write(meta_file,replace(text,"\"symbol_format_version\" => 1"=>"\"symbol_format_version\" => 99"))
                @test_throws ArgumentError load_fusion_category(path)
                # Pre-metadata archives still decode as column-major packing.
                untagged = join(filter(l -> !occursin("symbol_format_version",l) && !occursin("symbol_convention",l),split(text,'\n')),'\n')
                write(meta_file,untagged)
                E = convention == :column_major_packing ? load_fusion_category(path) : load_fusion_category(path;convention)
                @test Dict(k=>coerce(v) for (k,v) in F_symbols(E;convention)) == F

                # Low-level exact readers use the explicitly supplied convention.
                @test TC.load_F_symbols(rank(C),K,joinpath(path,"category_F_symbols");convention) == C.ass
                @test TC.load_R_symbols(rank(C),K,joinpath(path,"category_R_symbols");convention) == C.braiding
                for (savefun,data,name) in ((TC.save_F_symbols,F,"F.jl"),(TC.save_R_symbols,R,"R.jl"))
                    file = joinpath(dir,name)
                    savefun(C,file;convention)
                    vectors = include(file)
                    @test Dict(k=>(K == QQ ? K(v...) : K(v)) for (k,v) in vectors) == data
                end

                ff,rf = joinpath(dir,"F.csv"),joinpath(dir,"R.csv")
                numeric_symbols_to_csv(ff,Fn;convention)
                numeric_symbols_to_csv(rf,Rn;convention)
                @test startswith(readline(ff),"#") == (convention == :bonderson)
                Kn = AcbField(128)
                decoded = TC._load_numeric_fusion_category(Fn,Rn,Kn;convention,check=true)
                loaded = load_numeric_fusion_category(ff,rf,Kn;check=true)
                same_matrices(decoded,loaded;numerical=true)
                @test multiplication_table(load_numeric_fusion_category(ff,Kn;check=true)) == multiplication_table(C)
                @test keys(numeric_symbols_from_csv(ff,Kn;convention)) == keys(F)
                if convention == :bonderson
                    @test_throws ArgumentError numeric_symbols_from_csv(ff;convention=other)
                    @test_throws ArgumentError load_numeric_fusion_category(ff,rf;convention=other)
                    # Headerless external Bonderson data can be declared explicitly.
                    for file in (ff,rf)
                        write(file,join(readlines(file)[2:end],'\n')*"\n")
                    end
                    same_matrices(decoded,load_numeric_fusion_category(ff,rf,Kn;convention,check=true);numerical=true)
                    # Mixed marked/unmarked files must not be silently combined.
                    numeric_symbols_to_csv(ff,Fn;convention)
                    @test_throws ArgumentError load_numeric_fusion_category(ff,rf,Kn)
                end
            end
        end
    end
end

@testset "Multiplicity and lazy symbol serialization" begin
    C = TC.su_3_3_subcategory()
    # Use a nonsymmetric R block so that a writer/reader convention mismatch
    # cannot be hidden by the constructor's diagonal braiding matrices.
    K = base_ring(C)
    P = matrix(K,2,2,[1,1,0,1])
    E = basis(Hom(C[2] ⊗ C[2],C[2]))
    V = TC.gauge_transform(C,Dict((2,2,2)=>[sum(P[i,j]*E[i] for i in 1:2) for j in 1:2]))
    V.braiding[2,2,2] = inv(P)*TC.r_symbol(C,2,2,2)*P
    for convention in (:column_major_packing,:bonderson)
        F,R = F_symbols(V;convention),R_symbols(V;convention)
        @test TC._fusion_rules_from_symbol_dictionary(F;convention,check=true)[1] == multiplication_table(V)
        @test TC.dict_to_associator(F;convention) == V.ass
        @test TC.dict_to_braiding(R;convention) == V.braiding
        emb = first(complex_embeddings(K))
        Fn = numeric_F_symbols(V,emb;convention,precision=128)
        Rn = numeric_R_symbols(V,emb;convention,precision=128)
        @test all(overlaps(Rn[k],emb(v,128)) for (k,v) in R)
        @test all(overlaps(Fn[k],emb(v,128)) for (k,v) in F)
        mktempdir() do dir
            TC.save_symbols(F,joinpath(dir,"F"),4;convention)
            TC.save_symbols(R,joinpath(dir,"R");convention)
            @test TC.load_F_symbols(rank(V),K,joinpath(dir,"F");convention) == V.ass
            @test TC.load_R_symbols(rank(V),K,joinpath(dir,"R");convention) == V.braiding
            ff,rf = joinpath(dir,"F.csv"),joinpath(dir,"R.csv")
            numeric_symbols_to_csv(ff,Fn;convention)
            numeric_symbols_to_csv(rf,Rn;convention)
            # CSV stores decimal approximations, not ball radii. Read at
            # lower precision than the exported coefficients for overlap tests.
            D = load_numeric_fusion_category(ff,rf,AcbField(64);check=true)
            @test multiplication_table(D) == multiplication_table(V)
            DF,DR = F_symbols(D;convention),R_symbols(D;convention)
            @test all(overlaps(DR[k],v) for (k,v) in Rn)
            @test all(overlaps(DF[k],v) for (k,v) in Fn)
        end
    end
    ass,braid = deepcopy(V.ass),deepcopy(V.braiding)
    set_associator!(V,similar(V.ass))
    set_braiding!(V,similar(V.braiding))
    set_attribute!(V,:six_j_symbol,(a,b,c,d)->ass[a,b,c,d])
    set_attribute!(V,:r_symbol,(a,b,c)->braid[a,b,c])
    @test !isassigned(V.ass,1,1,1,1)
    @test TC.dict_to_associator(F_symbols(V;convention=:bonderson);convention=:bonderson) == ass
    @test TC.dict_to_braiding(R_symbols(V;convention=:bonderson);convention=:bonderson) == braid
end
