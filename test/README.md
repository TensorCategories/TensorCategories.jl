# Running tests

The test entry point supports two suites. With no environment variable it runs
the **full** suite, so `Pkg.test()` and direct local runs retain the existing
comprehensive behavior.

| Suite | Intended use | Current coverage |
| --- | --- | --- |
| `quick` | Every push and pull request | Finite-dimensional vector spaces, skeletal fusion arithmetic, exact associator coherence, and bounded categorical-interface regressions. |
| `full` | Locally before releases or substantial mathematical changes | The quick checks plus examples, group representations, centers, centralizers, module categories, group actions, equivariantization, and AnyonWiki. |

From the repository root:

```sh
# Quick feedback
TENSORCATEGORIES_TEST_SUITE=quick julia --project=. --startup-file=no test/runtests.jl

# Full validation (explicitly overrides a quick setting in the environment)
TENSORCATEGORIES_TEST_SUITE=full julia --project=. --startup-file=no test/runtests.jl
```

Alternatively, from Julia:

```julia
using Pkg
withenv("TENSORCATEGORIES_TEST_SUITE" => "full") do
    Pkg.test()
end
```

Invalid suite names fail immediately rather than silently omitting coverage.
No previously active test has been removed from the full suite. The group
representation tests disabled for a GAP MeatAxe regression in Oscar 1.8.0 are
enabled again after verification with Oscar 1.8.1. Other tests whose includes
were already commented out remain dormant.

## Mathematical literature checks

`LiteratureTests.jl` belongs to the full suite. It checks exact examples and
independent consequences rather than treating agreement with an older package
version as evidence. The center benchmarks derive fusion multiplicities from
central Hom spaces, compare quantum doubles with group-character formulas, and
check modular identities for full matrices. Numerical ball tests are marked as
compatibility checks, not exact certificates.

Principal sources are EGNO, *Tensor Categories* (AMS, 2015); Rowell--Stong--
Wang, [arXiv:0712.1377v4](https://arxiv.org/pdf/0712.1377v4); Müger,
[arXiv:math/0111205v1](https://arxiv.org/pdf/math/0111205v1), Theorem 1.2;
Gelaki--Naidu--Nikshych, *Algebra & Number Theory* 3 (2009), Section 4A;
Etingof--Ostrik, [arXiv:1801.04409v4](https://arxiv.org/pdf/1801.04409v4);
and Krause, [arXiv:1410.2822v1](https://arxiv.org/pdf/1410.2822v1).

## GitHub Actions

Push and pull-request runs select **quick** on the existing Julia 1.11/1.12 and
Ubuntu/macOS matrix. Open **Actions → Runtests → Run workflow** to run **full**
manually on a release-candidate branch or tag. Manual full-suite runs use one
Ubuntu runner with Julia 1.12, avoiding four repetitions of the expensive
coverage workload. A manual full run is not cancelled by a later push, while
superseded automatic runs are cancelled.

Only full runs collect and upload coverage, so a quick result does not replace
the comprehensive coverage report. The upload uses `CODECOV_TOKEN` when that
repository secret is configured; otherwise Codecov must permit tokenless
uploads. Dependencies and compilation artifacts are cached. A fresh job may
still spend substantial time installing and compiling Oscar: “quick” refers to
the selected test workload, not a guaranteed CI wall-clock duration.
