"""
    pentagon_axiom(X::T, Y::T, Z::T, W::T) where T <: Object

Check the pentagon axiom for ```X, Y, Z, W```.
"""
function pentagon_axiom(X::T, Y::T, Z::T, W::T) where T <: Object
    if typeof(base_ring(X)) <: Union{ArbField, ComplexField, AcbField}
        return pentagon_axiom_numeric(X, Y, Z, W)
    end 

    f = (id(X)⊗associator(Y,Z,W)) ∘ associator(X,Y⊗Z,W) ∘ (associator(X,Y,Z)⊗id(W))
    g = associator(X,Y,Z⊗W) ∘ associator(X⊗Y,Z,W)
    return f == g
end

function pentagon_axiom_numeric(X::T, Y::T, Z::T, W::T) where T <: Object
    f = (id(X)⊗associator(Y,Z,W)) ∘ associator(X,Y⊗Z,W) ∘ (associator(X,Y,Z)⊗id(W))
    g = associator(X,Y,Z⊗W) ∘ associator(X⊗Y,Z,W)
    return overlaps(matrix(f), matrix(g))
end

"""
    pentagon_axiom(objects::Vector{<:Object}, log::Bool = false)

Check the pentagon axiom for all combinations of objects in ```objects```. If
```log = true``` an array with the failing combinations is returned
"""
function pentagon_axiom(objects::Vector{<:Object}, log::Bool=false; show_progress=false)
    # Check unit-containing quadruples too: a constructor can supply
    # unnormalised (or invalid) unit F-symbols. EGNO, Definition 2.1.1.
    # A serial traversal also makes the complete failure list deterministic;
    # the old threaded push! and counter updates raced on shared state.
    failed = Tuple{Object,Object,Object,Object}[]
    N = length(objects)^4
    checked = 0
    for x in objects,y in objects,z in objects,w in objects
        if !pentagon_axiom(x,y,z,w)
            push!(failed,(x,y,z,w))
            !log && return false
        end
        checked += 1
        show_progress && print("\rChecked $checked / $N combinations")
    end
    show_progress && println()
    log ? (isempty(failed),failed) : isempty(failed)
end

function randomized_pentagon_axiom(C::Category, n::Int = 0)
    S = simples(C)
    m = length(S)
    if n == 0
        n = m^2
    end

    for _ ∈ 1:n
        if !pentagon_axiom(S[rand(1:m, 4)]...)
            return false
        end
    end

    true
end

"""
    pentagon_axiom(C::Category, log::Bool = false)

Check the pentagon axiom for all combinations of  simple objects of ```C```. If 
```log = true``` an array with the failing combinations is returned
"""
pentagon_axiom(C::Category, log::Bool = false; show_progress = false) = pentagon_axiom(simples(C), log, show_progress = show_progress)
