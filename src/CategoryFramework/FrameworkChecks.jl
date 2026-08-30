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
    try
        return det(smatrix(C)) != 0 
    catch 
        return false 
    end
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
    @assert is_multifusion(C) "Generic checking only available for multifusion categories"

    obj_type = typeof(one(C))
    if  !hasmethod(spherical, Tuple{obj_type})
        return false
    end
    try 
        for x ∈ simples(C)
            spherical(x)
        end
        return true
    catch
        return false
    end
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
