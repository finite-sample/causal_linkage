# Choosing an analysis

| Available information | Implemented analysis | What must be true | What the output means |
|---|---|---|---|
| Complete randomized experiment with known correct identities | `neyman()` | Complete assignment; consistency; no interference; defined target | Point estimate and approximate Neyman normal interval |
| Independent probability validation sample of anchor units | `audit_correct()` | Recover true treatment/outcome; known arm counts; scores fixed before sampling; SRS without replacement | Unbiased finite-population effect estimate and variance estimator conservative in expectation; Wald interval approximate |
| Accuracy audit plus homogeneous effect/permutation model | `attenuation_correct()` | Assignment-independent permutation; homogeneous effects or appropriate equal correctness probabilities; variance/covariance approximation justified | Model-based correction; approximate delta interval; weak factor is a failure |
| Candidate graph and overlap restrictions | `linkage_bounds()` | Correct unit; injectivity; specified cardinality; true links within graph/budgets; valid missing-outcome support | Sharp range of a fixed linear reconstructed statistic |
| Same graph plus known support of **both potential outcomes** | `causal_bounds()` | Complete assignment on all anchors plus the graph assumptions | Conservative causal CI; graph failure probability adds to noncoverage |
| Small complete graph reconstruction set and actual assignment law | `graph_null_p()` | Complete randomized assignment; truth included; no missing outcomes; sharp null | Exact conservative sharp-null p-value; enumeration stops at explicit size limits |
| Complete treated roster and complete outcome population | `roster_bounds()` | Every treated record matches once; roster exhaustive; controls are complement | Range of realized treatment/control contrast with correct fixed denominators |
| Independently resolved candidate identity | `review_priority()` | Reviewer resolves a source to a feasible candidate; full matching; graph is correct | Best and worst reduction in statistic range, not expected value without probabilities |
| Observational data with uncertain covariates | Formalization only | Oracle exchangeability/positivity plus validated linkage or correctly specified linkage model | No generic causal guarantee from fuzzy-link weights or doubly robust fitting |

An edge score is not a probability unless calibrated for the intended event and
population. High precision does not establish candidate recall, full overlap, or
representative retention. Exact names are not ground truth. Fixed cohort, treatment
roster, and common target are required for interpretable method comparisons.

A confidence set spanning linkages protects against uncertainty represented in its
feasible set. If true links were blocked out, a sensitivity budget must allow those
edges; if counterparts are absent, finite outcome support or another missing-data
assumption is needed. These are distinct adjustments. Declaring every source matched
because it has a candidate can make a narrow interval invalid.

The research code rejects impossible matchings and missing support; it does not
silently return zeros. Large complete graphs with non-network error budgets can be
expensive. Review planning should keep some probability validation for estimation;
a purely targeted review sample cannot use the SRS correction formula.
