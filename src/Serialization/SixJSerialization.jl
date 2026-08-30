#=----------------------------------------------------------
    Serialize Categories of Type SixJCategory 
----------------------------------------------------------=#

const database_path = joinpath(@__DIR__,"src/SixJCategoryDatabase/")

function save_object(s::SerializerState, C::SixJCategory)
    save_data_dict(s) do 

        save_typed_object(s, base_ring(C), :base_ring)

        save_object(s, C.rank, :rank)

        save_object(s, Tuple(simples_names(C)), :simples_names)
        # save_data_array(s, :simples_names) do   
        #     for n ∈ simples_names(C) 
        #         save_object(s,n)
        #     end
        # end

        save_object(s, Tuple(C.tensor_product), :tensor_product)
        # save_data_array(s, :tensor_product) do 
        #     for x ∈ C.tensor_product 
        #         save_object(s,x)
        #     end
        # end

        #save_typed_object(s, Dict(Tuple(k) => v for (k,v) ∈ F_symbols(C)), :F_symbols)
        save_data_array(s, :ass) do 
            for I in CartesianIndices(C.ass)
                save_object(s, six_j_symbol(C,Tuple(I)...))
            end
        end

        
        #save_typed_object(s,C.spherical, :spherical)

        if isdefined(C, :pivotal)
            save_typed_object(s, Tuple(C.pivotal), :pivotal)
        end

        if isdefined(C, :embedding)
            save_typed_object(s, getfield(C, :embedding), :embedding)
        end

        if isdefined(C, :one)
            save_object(s, Tuple(C.one), :one)
        end

        if isdefined(C, :name)
            save_object(s, C.name, :name)
        end

        if is_braided(C)
            save_data_array(s, :braiding) do 
                for I in CartesianIndices(C.braiding)
                    save_object(s, r_symbol(C,Tuple(I)...))
                end
            end
        end
    end
end

function load_object(s::DeserializerState, ::Type{SixJCategory})
    C = SixJCategory()
    
    C.base_ring = load_typed_object(s, :base_ring)
    
    C.rank = load_object(s, Int64, :rank)
    
    n = C.rank

    C.simples_names = collect(load_object(s, NTuple{n, String}, :simples_names))

    # C.simples_names = load_array_node(s, :simples_names) do (i,n)
    #     load_object(s, String)
    # end



    C.tensor_product = reshape(
        collect(load_object(s, NTuple{n^3 ,Int}, :tensor_product)),
        n,n,n
    )

    m = maximum(C.tensor_product)
    _n = m == 1 ? 6 : 10

    # F_symb = Dict(collect(k) => v for (k,v) ∈ load_typed_object(s, :F_symbols))

    # set_attribute!(C, :F_symbols, F_symb)
    # ass = dict_to_associator(n, base_ring(C), F_symb)

    # C.ass = ass
    C.ass = reshape(
        load_array_node(s, :ass) do (i,m)
            m = load_object(s, Matrix{elem_type(base_ring(C))}, base_ring(C))
            a = size(m,1)
            b = length(size(m)) == 2 ? size(m,2) : 0
            matrix(base_ring(C), a, b, m)
        end,
        n,n,n,n
    )


    if haskey(s, :pivotal)
       C.pivotal = collect(load_typed_object(s, :pivotal))
    end

    if haskey(s, :one)
        C.one = collect(load_object(s, NTuple{n,Int64}, :one))
    end

    if haskey(s, :embedding)
        C.embedding = load_typed_object(s, :embedding)
    end

    if haskey(s, :name)
        C.name = load_object(s, String, :name)
    end

    if haskey(s, :braiding)
        C.braiding = reshape(
            load_array_node(s, :braiding) do (i,m)
                m = load_object(s, Matrix{elem_type(base_ring(C))}, base_ring(C))
                a = size(m,1)
                b = length(size(m)) == 2 ? size(m,2) : 0
                matrix(base_ring(C), a, b, m)
            end,
        n,n,n
    )
    end

    
    return C
end

#=----------------------------------------------------------
    Serialize SixJMorphism 
----------------------------------------------------------=#

Oscar.Serialization.type_and_params(X::SixJObject) =
    Oscar.Serialization.TypeAndParams(SixJObject,parent(X))

function save_object(s::SerializerState, X::SixJObject)
    save_data_dict(s) do 
        save_object(s, X.components, :components)
    end
end

function load_object(s::DeserializerState, ::Type{SixJObject},C::SixJCategory)
    components = load_object(s, Vector{Int}, :components)
    return SixJObject(C,components)
end

Oscar.Serialization.type_and_params(f::SixJMorphism) =
    Oscar.Serialization.TypeAndParams(SixJMorphism,parent(domain(f)))

function save_object(s::SerializerState, f::SixJMorphism)
    save_data_dict(s) do 
        save_object(s, domain(f).components, :domain_components)
        save_object(s, codomain(f).components, :codomain_components)
        save_data_array(s, :mats) do
            for M in matrices(f)
                save_object(s,M)
            end
        end
    end
end

function load_object(s::DeserializerState, ::Type{SixJMorphism},C::SixJCategory)
    X = SixJObject(C,load_object(s,Vector{Int},:domain_components))
    Y = SixJObject(C,load_object(s,Vector{Int},:codomain_components))
    mats = load_array_node(s,:mats) do (i,n)
        M = load_object(s,Matrix{elem_type(base_ring(C))},base_ring(C))
        matrix(base_ring(C),size(M)...,M)
    end
    return morphism(X,Y,mats)
end
