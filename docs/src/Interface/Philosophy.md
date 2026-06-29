# [The Motivation](@id interface-philosophy)

This package began its journey asking the question "Can we play around 
with explicit categorical entities in the computer?".

By nature categorical operations and constructions are generic and abstract. The categorical language therefore provides a framework of construction that can be performed as long as the objects (or morphisms) play along. TensorCategories.jl aims to provide an interface for categories with additional 
structure like additive, linear, abelian, monoidal, tensor and 
fusion categories. The main focus though lies in fusion and finite tensor categories.

# Realizing Categories in The Computer

Due to the nature of category theory the realization of certain categories 
is very dependent on themselves. Thus the internal workings are generally 
up to the user. As long as the interface for the desired additional
structures is implemented. 

Some kind of categories, i.e. fusion categories, are entirely described
(up to equivalence) by discrete data known as ``F``-symbols. Thus 
for such categories we can provide a datatype [`SixJCategory`](../SixJCategories/SixJCategories.md) 
to quickly work with categories given by such data.

# Mathematical Foundation

Throughout the package we will consider definitions and terminology as
provided in [EGNO](@cite).