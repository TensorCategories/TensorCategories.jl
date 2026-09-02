# [Relative centers](@id centralizer)

For a tensor subcategory $\mathcal D\subseteq\mathcal C$, the relative center
has objects of $\mathcal C$ with half-braidings only against objects of
$\mathcal D$. The implemented name is
`centralizer(C,generators)`; its stored components use the simple objects of
the generated subcategory.

This is not the Müger centralizer, whose objects in a braided category satisfy
a double-braiding identity. The relative center has additional half-braiding
data and uses the direction specified for the [Drinfeld center](Center.md).

The implementation is experimental. It requires finite semisimple subcategory
enumeration and the induction operations of the ambient category.
