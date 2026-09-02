using Documenter, TensorCategories, Oscar, DocumenterCitations

DocMeta.setdocmeta!(TensorCategories, :DocTestSetup,
    :(using TensorCategories, Oscar); recursive=true, warn=false)
bib = CitationBibliography(joinpath(@__DIR__, "src", "MyBib.bib");
    style=:authoryear)

function check_rendered_example_outputs(build_dir)
    raw_output = r"</code></pre>\s*[^<\s]"
    for (root, _, files) in walkdir(build_dir)
        for file in files
            endswith(file, ".html") || continue
            path = joinpath(root, file)
            occursin(raw_output, read(path, String)) || continue
            error("unformatted example output in $(relpath(path, build_dir))")
        end
    end
end

# Home links to the repository's legal notices. Stage these without maintaining
# duplicate source copies or changing the Home page.
legal_files = ("LICENSE", "COPYRIGHT")
try
    for name in legal_files
        cp(joinpath(@__DIR__, "..", name), joinpath(@__DIR__, "src", name); force=true)
    end
    makedocs(
        root = @__DIR__,
        plugins = [bib],
        sitename = "TensorCategories.jl",
        modules = [TensorCategories],
        checkdocs = :exports,
        warnonly = false,
        format = Documenter.HTML(
            edit_link = "master",
            canonical = "https://TensorCategories.github.io/TensorCategories.jl/stable/",
            prettyurls = !("local" in ARGS),
            collapselevel = 1,
            mathengine = MathJax3(Dict(
                :tex => Dict(
                    "inlineMath" => [["\$","\$"], ["\\(","\\)"]],
                    "tags" => "ams",
                    "packages" => ["base", "ams", "autoload"],
                ),
            )),
        ),
        pages = [
            "Home" => "index.md",
            "Getting started" => [
                "Julia and OSCAR" => "Basics/Julia.md",
                "Coefficient fields" => "Basics/BaseFields.md",
                "First computations" => "Introduction/Introduction.md",
                "Anyons and CFT" => "Basics/Physics.md",
            ],
            "The categorical framework" => [
                "Models and interface" => "Interface/Philosophy.md",
                "Objects and morphisms" => "Interface/Categories.md",
                "Linear categories" => "Interface/LinearCategories.md",
                "Matrices and fiber functors" => "Interface/MatrixRealizations.md",
                "Additive and abelian categories" => "Interface/AbelianCategories.md",
                "Tensor products and duality" => "Interface/MonoidalCategories.md",
                "Fusion and splitting" => "Interface/TensorCategories.md",
                "Grothendieck rings" => "Interface/GrothendieckRings.md",
                "Functors" => "Interface/AdvancedInterface.md",
            ],
            "Implementing categories" => [
                "A complete matrix example" => "Implementing/MatrixCategory.md",
                "Graded spaces and representations" => "Implementing/ConcreteModels.md",
                "Interface checklist" => "Interface/Generic.md",
            ],
            "Fusion categories and F-symbols" => [
                "Skeletal models" => "F-symbols/SkeletalFusion.md",
                "Precise conventions" => "F-symbols/Conventions.md",
                "Working with fusion data" => "F-symbols/WorkedExamples.md",
                "Data exchange" => "F-symbols/Data.md",
            ],
            "Numerical computations" => "Basics/Numerical.md",
            "Catalogue" => [
                "Inventory" => "F-symbols/Examples.md",
                "AnyonWiki" => "F-symbols/AnyonWiki.md",
                "Fibonacci" => "F-symbols/Fibonacci.md",
                "Finite sets" => "ConcreteExamples/Sets.md",
                "Group representations" => "ConcreteExamples/Representations.md",
                "Haagerup" => "F-symbols/Haagerup.md",
                "Other supplied data" => "F-symbols/OtherExamples.md",
                "Sheaves and convolution" => "ConcreteExamples/CoherentSheaves.md",
                "sl₂, Verlinde, and dihedral models" => "ConcreteExamples/UqSl2.md",
                "Tambara–Yamagami and Ising" => "F-symbols/TambaraYamagami.md",
                "Vector spaces and gradings" => "ConcreteExamples/VectorSpaces.md",
            ],
            "Drinfeld centers" => [
                "Half-braidings and computation" => "Constructions/Center.md",
                "The Ising center and splitting" => "Introduction/Ising.md",
                "Relative centers" => "Constructions/Centralizer.md",
            ],
            "Further constructions" => [
                "Products and scalar extension" => "Interface/BasicConstructions.md",
                "Algebras and internal modules" => "Constructions/ModuleCategories.md",
                "Group actions" => "Constructions/GroupActions.md",
            ],
            "API reference" => [
                "Index" => "API.md",
                "Category interface" => "API/Framework.md",
                "Tensor structure" => "API/TensorStructure.md",
                "Concrete categories" => "API/Categories.md",
                "Fusion data and databases" => "API/FusionData.md",
                "Constructions" => "API/Constructions.md",
                "Utilities" => "API/Utilities.md",
            ],
            "References" => "References.md",
            "Project" => [
                "Developing" => "Project/Developing.md",
                "Citations" => "Project/Citations.md",
                "Further literature" => "Project/FurtherLiterature.md",
            ],
            hide("SixJCategories/SixJCategories.md"),
        ],
    )
    check_rendered_example_outputs(joinpath(@__DIR__, "build"))
finally
    for name in legal_files
        rm(joinpath(@__DIR__, "src", name); force=true)
    end
end

if "deploy" in ARGS
    deploydocs(
        repo = "github.com/TensorCategories/TensorCategories.jl.git",
        devbranch = "master",
    )
end
