# Validation record

Validated locally on 2026-10-08 with the R and package versions in `renv.lock`.

- `make check`: 14 test cases, 161 expectations, zero failures/errors; all 12 R files
  pass the configured default linters (100-character line limit).
- Exhaustive assignment checks verify the fixed-permutation expectation, including
  unequal arm sizes and heterogeneous effects. Enumerated validation samples verify
  conditional unbiasedness and the conservative variance expectation.
- Forty randomized small-graph cases compare optimization with independent exhaustive
  enumeration. Additional tests cover outside options, missing-edge/trusted-link
  budgets, complete treated rosters, joint-field movement, selection, and sharp-null size.
- The independent reviewer separately checked 30 budgeted graphs, a sparse-validation
  experiment, an adaptive-graph test, the binary-confounder identity, and the identical-law
  nonidentification construction. Its three input-contract findings were repaired and
  covered by regression tests. See `independent-review.md`.
- Main simulations use 200 pilot and 2,000 final replications per cell: 16 scenarios
  at two effect levels. All replication outputs are saved. The observational illustration
  adds five 2,000-replication cells and reproduces the analytic expectations within
  Monte Carlo error.
- The application exactly reproduces the accepted 4,355 links. The implementing agent
  independently refit the reported regression and refit each of the four endpoint witness
  datasets; every witness coefficient agrees with its optimized endpoint within 1e-8.
- All source hashes in the application's manifest were checked again and remain
  unchanged. The source repository was read only.
- LaTeX tables and interpretation paragraphs are generated from CSV outputs. The PDF
  compiles without undefined citations or layout warnings; every page was visually
  inspected. The saved graph ranges are explicitly distinguished from causal intervals.

These checks establish implementation consistency on the stated domains. They do not
validate application identities, reconstruct missing historical lottery records, prove
normal-approximation coverage, or establish originality. The full simulation reports
include Monte Carlo standard errors and interval failure counts. Sparse selected
arms can make a comparator undefined; its reported coverage conditions on successful
intervals, with the failure count retained rather than silently dropped.
