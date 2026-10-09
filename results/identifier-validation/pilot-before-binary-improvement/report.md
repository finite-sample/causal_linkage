# Outcome-blind identifier validation

Phase: pilot ; 96 evaluations; 1 failures.

Identifiers and accepted assignments precede treatment and outcome generation.
True-graph containment follows the bounded corruption mechanism. Both robust
methods receive the same oracle-known identity-error budget: a privileged input,
not an estimated real-data accuracy guarantee. All donor outcomes are conserved.

Completed solves are exact; a solver failure receives conservative p=1. Graph p-values are
maximized over candidate-compatible bijections; accuracy-only p-values use the
closed-form binary success-count support. Every saved endpoint witness is checked.

summary.csv reports rejection rates with Wilson 95% intervals and paired power
differences with Monte Carlo standard errors. Zero estimated MCSE when every
paired difference is zero does not prove a zero population difference. Null
rejection frequencies are noisy diagnostics, not a proof of test size. No
failed run is excluded from rejection rates. Graph widths summarize completed solves only.
The three ILP calls each have a three-second time limit; exact_completion reports
the successful fraction. Computational fallback can reverse the theoretical power ordering.

| n | Noise | Baseline | Effect | Oracle | Graph | Accuracy | Gain (MCSE) |
|---:|---:|:---|---:|---:|---:|---:|:---|
| 40 | 0.25 | geographic | 0.00 | 0.000 | 0.000 | 0.000 | 0.000 (0.000) |
| 80 | 0.25 | geographic | 0.00 | 0.000 | 0.000 | 0.000 | 0.000 (0.000) |
| 40 | 0.75 | geographic | 0.00 | 0.250 | 0.000 | 0.000 | 0.000 (0.000) |
| 80 | 0.75 | geographic | 0.00 | 0.000 | 0.000 | 0.000 | 0.000 (0.000) |
| 40 | 0.25 | uniform | 0.00 | 0.000 | 0.000 | 0.000 | 0.000 (0.000) |
| 80 | 0.25 | uniform | 0.00 | 0.000 | 0.000 | 0.000 | 0.000 (0.000) |
| 40 | 0.75 | uniform | 0.00 | 0.000 | 0.000 | 0.000 | 0.000 (0.000) |
| 80 | 0.75 | uniform | 0.00 | 0.000 | 0.000 | 0.000 | 0.000 (0.000) |
| 40 | 0.25 | geographic | 0.25 | 0.250 | 0.000 | 0.000 | 0.000 (0.000) |
| 80 | 0.25 | geographic | 0.25 | 0.500 | 0.000 | 0.000 | 0.000 (0.000) |
| 40 | 0.75 | geographic | 0.25 | 0.750 | 0.250 | 0.000 | 0.250 (0.250) |
| 80 | 0.75 | geographic | 0.25 | 0.250 | 0.000 | 0.000 | 0.000 (0.000) |
| 40 | 0.25 | uniform | 0.25 | 0.250 | 0.000 | 0.000 | 0.000 (0.000) |
| 80 | 0.25 | uniform | 0.25 | 0.250 | 0.000 | 0.000 | 0.000 (0.000) |
| 40 | 0.75 | uniform | 0.25 | 0.000 | 0.000 | 0.000 | 0.000 (0.000) |
| 80 | 0.75 | uniform | 0.25 | 1.000 | 0.000 | 0.000 | 0.000 (0.000) |
| 40 | 0.25 | geographic | 0.50 | 0.750 | 0.000 | 0.000 | 0.000 (0.000) |
| 80 | 0.25 | geographic | 0.50 | 1.000 | 0.000 | 0.000 | 0.000 (0.000) |
| 40 | 0.75 | geographic | 0.50 | 1.000 | 0.250 | 0.000 | 0.250 (0.250) |
| 80 | 0.75 | geographic | 0.50 | 1.000 | 0.000 | 0.000 | 0.000 (0.000) |
| 40 | 0.25 | uniform | 0.50 | 1.000 | 0.000 | 0.000 | 0.000 (0.000) |
| 80 | 0.25 | uniform | 0.50 | 1.000 | 0.000 | 0.000 | 0.000 (0.000) |
| 40 | 0.75 | uniform | 0.50 | 0.750 | 0.000 | 0.000 | 0.000 (0.000) |
| 80 | 0.75 | uniform | 0.50 | 1.000 | 0.000 | 0.000 | 0.000 (0.000) |

These controlled results do not establish practical value for real linkage
pipelines. Real application requires defensible graph containment and an
error budget supplied by validation, not by access to true identities.
