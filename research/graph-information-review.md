# Review of the candidate-graph information analysis

Reviewed 2026-10-08. The review concerns the mathematical assumptions, implemented
randomization test, and controlled comparison in `research/graph-information.md`.
An independent agent inspected the code and proofs and independently reproduced
the comparison by enumerating linkages and assignments in Python.

The review verified the alternating-cycle characterization, component additivity,
complete-block width formula, full-bijection common randomization law, and
containment-adjusted p-value argument. It independently reproduced all reported
rejection counts and mean widths. No blocking mathematical or implementation
issue remained.

The review prompted explicit distinctions incorporated in the analysis:

- At most two errors is an upper-bound assumption; 75% is realized accuracy in
  the example, not a restriction that exactly two links must be wrong.
- The graphs are controlled information sets, not an operational graph-learning
  procedure or an empirically calibrated claim about candidate recall.
- Component additivity and the individual-cycle criterion are stated without a
  shared error budget, which can couple components.
- A common randomization reference distribution does not imply a common observed
  contrast. Under alternatives, realized donor outcomes also depend on assignment.
- The two graph structures are not nested and neither uniformly dominates in
  power. The low-power effect-one case is retained; effects two and four show the
  substantial power loss remaining relative to known identities.
- Sharp-null testing is distinct from testing an average zero effect under
  heterogeneous individual effects.

Validation combines independent enumeration of random small graphs, every
assignment in the eight-unit comparison, a large binary case using the exact
hypergeometric reference, and input-contract checks. No website, original quota
input, or empirical application claim was changed for this extension.
