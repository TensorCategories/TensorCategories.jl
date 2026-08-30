#=----------------------------------------------------------
    Generic checks for categories 
----------------------------------------------------------=#

# Structural predicates report declared or category-specific knowledge. Generic
# methods cannot prove axioms merely from the existence of other methods.
_declared_structure(C::Category, key::Symbol) =
    hasfield(typeof(C), :__attrs) && get_attribute(C, key, false) === true

is_fusion(C::Category) = _declared_structure(C, :fusion)
is_multifusion(C::Category) = is_fusion(C) || _declared_structure(C, :multifusion)
is_weak_fusion(C::Category) = is_fusion(C) || _declared_structure(C, :weak_fusion)
is_weak_multifusion(C::Category) = is_multifusion(C) || is_weak_fusion(C) ||
    _declared_structure(C, :weak_multifusion)

function is_split_semisimple(C::Category)
    is_multifusion(C) && return true
    is_semisimple(C) && all(s -> int_dim(End(s)) == 1, simples(C))
end

is_tensor(C::Category) = is_weak_fusion(C) || _declared_structure(C, :tensor)
is_multitensor(C::Category) = is_tensor(C) || is_weak_multifusion(C) ||
    _declared_structure(C, :multitensor)
is_ring(C::Category) = is_tensor(C) || _declared_structure(C, :ring)
is_multiring(C::Category) = is_multitensor(C) || is_ring(C) ||
    _declared_structure(C, :multiring)

is_finite(C::Category) = is_weak_multifusion(C) || _declared_structure(C, :finite)
is_monoidal(C::Category) = is_multiring(C) || any(
    key -> _declared_structure(C, key), (:monoidal, :rigid, :spherical, :is_braided))
is_abelian(C::Category) = is_multiring(C) || _declared_structure(C, :abelian)
is_additive(C::Category) = is_abelian(C) || _declared_structure(C, :additive)
is_linear(C::Category) = is_multiring(C) || _declared_structure(C, :linear)
is_semisimple(C::Category) = is_weak_multifusion(C) ||
    _declared_structure(C, :semisimple)

function is_modular(C::Category) 
    if hasfield(typeof(C), :__attrs) 
        return get_attribute!(C, :modular) do
            _is_modular(C)
        end
    end

    _is_modular(C)
end

function _is_modular(C::Category) 
    is_fusion(C) && is_braided(C) && is_spherical(C) || return false
    base_ring(C) isa Union{ArbField,AcbField,ComplexField} &&
        throw(ArgumentError(
            "numerical overlap does not certify modularity; use exact category data"))
    !iszero(det(smatrix(C)))
end

function is_spherical(C::Category)
    if hasfield(typeof(C), :__attrs) 
        return get_attribute!(C, :spherical) do
            _is_spherical(C)
        end
    end
    _is_spherical(C)
end

function _is_spherical(C::Category)
    # EGNO, Section 4.7: for a split semisimple pivotal category it suffices
    # to compare the left and right dimensions on simple objects. A method
    # producing components does not by itself prove pivotal monoidality.
    is_split_semisimple(C) || return false
    S = simples(C)
    all(X -> applicable(spherical,X),S) || return false
    is_pivotal(C) || return false
    if base_ring(C) isa Union{ArbField,AcbField,ComplexField}
        return all(overlaps(dim(X),dim(dual(X))) for X in S)
    end
    all(dim(X) == dim(dual(X)) for X in S)
end

function is_rigid(C::Category)
    is_multitensor(C) || _declared_structure(C, :rigid) ||
        _declared_structure(C, :spherical)
end

is_braided(C::Category) = _declared_structure(C, :is_braided)

function is_krull_schmidt(C::Category)
    is_multiring(C) || _declared_structure(C, :krull_schmidt)
end

is_unitary(C::Category) = false
#=----------------------------------------------------------
    Helpers 
----------------------------------------------------------=#

function all_subtypes(T::Type)
    sub_types = subtypes(T)
    
    is_abstract = isabstracttype.(sub_types)

    concrete_types = sub_types[true .⊻ (is_abstract)]
    abstract_types = sub_types[is_abstract]

    return [concrete_types; vcat(all_subtypes.(abstract_types))...]
end


function object_type(C::Category)
    object_types = all_subtypes(Object)

    for T ∈ object_types
        if hasfield(T, :parent)
            if typeof(C) == fieldtype(T,:parent)
                return T
            end
        end
    end
end

function morphism_type(C::Category)
    morphism_types = all_subtypes(Morphism)

    for T ∈ morphism_types
        if hasfield(T, :domain)
            if object_type(C) == fieldtype(T,:domain)
                return T
            end
        end
    end
end
