# Candidate-constrained causal randomization inference: contribution assessment

## What has actually been done before?

### Takeaway
The closest papers establish the component ideas, including whole-matching confidence sets and causal sensitivity to outcome errors. I did not find this exact design-based test for identity uncertainty in their full texts or in targeted searches. The strongest defensible contribution is a focused method specialization and analysis of what candidate information buys, not a new general principle of robust inference.

### Cited Findings
- **Hall and Fienberg (2012), an important additional antecedent.** Sections 2–4 construct confidence sets of bipartite matchings using linear constraints. Equation (7) claims whole-matching coverage at least 1−α−β. Section 5 optimizes statistics over the set, explicitly distinguishing coverage of the oracle statistic from coverage of the population parameter. Calibration assumes a factorized pair/singleton data model with symmetric paired density and equal marginal distributions; rejecting false links additionally uses a distance model. Their permutation test concerns linkage, not randomized treatment. Their downstream computation is a greedy approximation. The author PDF includes draft placeholders, so its approximation claims should not be adopted without checking. [Author full text](https://www.cs.cmu.edu/~rjhall/linkage.pdf); [published chapter, PSD 2012](https://link.springer.com/chapter/10.1007/978-3-642-33627-0_11).
- **Heng and Shaw (2025; preprint 2022).** Definition 1 minimizes outcome alterations needed to reverse a causal test. Section 4.1, problem P0, optimizes binary outcomes with a test-decision constraint; page 17 explicitly permits additional linear restrictions. The implemented main sharp-null procedure uses a chi-square approximation to the Mantel–Haenszel statistic, although the motivating framework is general. They also discuss weak-null tests and multiple randomization designs. They do not supply an identity candidate graph or a donor-conserving matching model. [Full text, version 3, January 2025, pp. 8–17](https://arxiv.org/pdf/2201.03111); [published article](https://doi.org/10.1080/10618600.2025.2461222).
- **Morucci, Noor-E-Alam, and Rudin (2022; preprint 2018).** They optimize causal test statistics over acceptable treated–control match assignments. Section 5.1 and Theorem 3 derive randomization behavior under binning constraints. The uncertainty concerns the analyst's choice of comparable distinct persons, including changes to selected samples; each person's outcome and identity are already known. Their treatment assignment assumptions and optimized statistics differ from the present identity-linkage problem. [Full text](https://arxiv.org/pdf/1812.02227); [published article](https://doi.org/10.1287/ijds.2022.0020).
- **Ota and Imaizumi (2026).** Theorems 4.1, 4.3, and 4.4 localize candidate permutations, test permutation sparsity, and propagate candidate-set uncertainty into coefficient confidence regions. The observation model is Gaussian linear regression with fixed design; it is not finite-population treatment randomization. It directly precedes generic claims about valid inference without uniquely recovering the alignment. ArXiv history dates versions 1–2 to January 21–22, 2026; the rendered text's August date conflicts, so use the repository history. [Full text](https://arxiv.org/html/2601.14872v2); [submission record](https://arxiv.org/abs/2601.14872).
- **Berger and Boos (1994).** Maximizing an oracle p-value over a nuisance confidence set and accounting for its possible failure is established methodology. This is the proper credit for the current containment-error adjustment. [Author institutional record and abstract](https://asu.elsevierpure.com/en/publications/p-values-maximized-over-a-confidence-set-for-the-nuisance-paramet/).
- **Wortman and Reiter (2018).** Section 3.1 already explains why exchanging treated outcomes within a propensity-score subclass leaves its unadjusted effect estimate unchanged and why covariate adjustment may change that conclusion. Thus, within-arm invariance alone is not a new causal insight. [Full text](https://arxiv.org/pdf/1709.03631).
- **Turkcapar and Krishnan (2023).** Candidate restrictions and donor competition inform weighted aggregate-query bounds through matching optimization. This is the appropriate computational antecedent for linear estimator ranges. [Full text](https://arxiv.org/html/2309.05178v1).

### Inferences
- Whole-reconstruction containment is not an entirely unexplored problem: Hall–Fienberg and Ota–Imaizumi explicitly address it under their respective assumptions. A validation-based construction suitable for randomized linked data could still differ, but novelty would require comparison against these constructions.
- A paper saying only “maximize over feasible linkages” would repeat an existing approach. A paper showing how identity information alters experimental inference, with explicit design-based guarantees and reproducible procedures, can make a narrower contribution even though the underlying maximization principle is inherited.
- The literal identity-constrained Fisher test was not established as an existing published method by this search. Conversely, failure to find it is not proof of priority.

### Gaps
- I inspected primary full texts for the closest methods; no exhaustive citation-network search or all dissertations can be claimed.
- Hall–Fienberg's author manuscript contains preliminary-looking approximation arguments. It establishes antecedent scope, but I have not independently validated its calibration construction or approximation ratio.
- Generic robust optimization and assignment theory may contain equivalent computational formulations under different applications. Their presence would limit an algorithmic priority claim without eliminating the causal application contribution.

## How much does the present test add to those antecedents?

### Takeaway
It supplies a usable exact sharp-null sensitivity analysis for a distinct uncertainty object: which experimental unit owns each observed donor outcome. That is a defensible incremental methodological contribution if presented with its actual restrictions and empirical value, rather than as a new invention of confidence-set inference.

### Cited Findings
- The current note assumes known completely randomized treatment, full overlap, one donor outcome per unit, and a feasible set of bijections with candidate, trusted-link-error, and optional off-graph budgets. Every reconstruction uses the same outcome multiset. The common sharp-null reference law reduces the maximum p-value to the tail probability at the minimum feasible absolute contrast. The code solves that minimum with binary edge variables and an absolute-value epigraph; binary outcomes use the hypergeometric law, other outcomes enumerate assignments up to a limit. [Current formalization](../../research/graph-information.md); [implementation](../../R/information.R).
- The procedure takes a simultaneous containment-failure bound as input and adds it to the optimized p-value. It does not learn that bound, identify unknown assignment designs, implement weak-null inference, or handle incomplete overlap. [Current formalization, Sections 4 and 6](../../research/graph-information.md).

### Inferences
**The actual extension relative to outcome misclassification can be stated algebraically.** Let v_i = sum_j x_ij y_j, where x is a binary matching matrix supported on the candidate graph. For binary y this embeds the present reconstruction set inside the binary-outcome space used in misclassification sensitivity. Yet the matching representation adds more than a numerical accuracy threshold:

1. Column constraints conserve the observed donor pool, including outcome totals.
2. Missing graph edges forbid particular ownership assignments, often inducing local conservation constraints.
3. An identity error is counted by x_i,pi0(i)=0, not by v_i differing from its accepted value. A donor exchange can be an identity error while moving an equal outcome and causing zero outcome error.
4. Distinct identity reconstructions can induce the same v, yet incur different identity-error budgets. A bare outcome-error Hamming ball cannot encode all this information.

This is a real extension of the uncertainty description. For binary outcomes, it can be implemented as an extended formulation of a constrained outcome-misclassification program, by introducing x and enforcing v=Xy. That is a short reduction, not proof the causal identity method was already published. It also means one should not advertise an unrelated new optimization paradigm. The graph structure may destroy the exchangeability that makes outcome-class aggregation computationally convenient; a generic MILP is a valid implementation, not a claim of a new scalable algorithm.

**Relative to Hall–Fienberg, the bridge is from an oracle-statistic range to an actual causal test.** Their separation of statistic and parameter uncertainty is already explicit. Here a known treatment design supplies the reference law, and complete overlap makes that law invariant across identity reconstructions. One optimization therefore delivers an attaining least-favorable linkage and an exact finite-sample sharp-null p-value. This is useful additional content, although the proof is brief and the general inferential logic established.

**Relative to causal treated–control matching, the probability experiment differs.** The present nuisance is a single unknown factual identity relation. Robustness is obtained because the true oracle analysis is among the feasible reconstructions. There is no claim that every feasible reconstruction is the true data-generating world or that the graph determines the treatment randomization support. That distinction prevents a careless transplant of matched observational-study validity arguments.

**The exactness is meaningful but narrow.** No outcome regression, distributional model, or random-mislinking mechanism is needed for the test conditional on valid restrictions. “No assumptions about linkage” would be false: full overlap and truthful reconstruction containment are strong assumptions. Nonbinary outcomes are supported mathematically, but assignment enumeration limits practical scale. Ordinary Monte Carlo approximation would require its own conservative p-value construction if added.

A defensible contribution sentence is:

> We develop a randomization sensitivity analysis for uncertain record identities that retains candidate-link restrictions and one-to-one donor conservation. Under complete randomization and full overlap, we compute an exact worst-case sharp-null p-value through a single matching-based integer program and show which identity ambiguities can change the causal conclusion.

This wording describes the method without asserting priority over all possible formulations.

### Gaps
- The method currently tests Fisher's sharp no-effect null, not an arbitrary average-treatment-effect null; effect confidence intervals and standard errors are not delivered by this function.
- Exact common-law reduction generally fails when candidate reconstructions alter the donor subset or blockwise outcome multisets. Those are scope boundaries, not defects in the stated theorem.
- There is no comparison of runtime and power against an explicitly identity-constrained Heng–Shaw implementation with the same information. Such a comparison would assess practical contribution, not decide whether elementary integration is allowed to count as research.

## Is this worth continuing, and what is the appropriate contribution claim?

### Takeaway
Yes: the candidate-graph direction supports a coherent, modest contribution centered on inference-relevant identity ambiguity. The current material is enough to motivate a focused methodological note; its practical strength still depends on realistic candidate sets and an application with a known assignment design.

### Cited Findings
- The controlled example fixes accepted linkage, 75% identity accuracy, degrees, donor pool, and reconstruction counts across two graphs, yet obtains worst-case p-values 2/70 and 34/70. Its first graph identifies the oracle contrast even with unresolved identities. The note also reports cases of low power and does not claim graph restrictions universally recover oracle inference. [Current example and exhaustive experiment](../../research/graph-information.md).

### Inferences
The contribution is strongest as a combination of three things: a sharper question (“which unresolved identities can affect this causal analysis?”), an explicit test answering it under a transparent design, and a demonstration that standard linkage summaries can conceal decisive information. It need not be a foundational invention to be useful or original in this application.

The previous assessment's binary choice between a substantial new general method and no contribution was too restrictive for this narrower project. The defensible current judgment is **promising incremental contribution, with a specific implemented method and a clear empirical evaluation target**. This is stronger than “novelty remains wholly unestablished,” and narrower than “the first causal method exploiting candidate graphs.”

The next substantive test is whether actual identifier-derived candidate restrictions preserve enough design-relevant information to change conclusions at an honest containment level. If yes, the paper has an applied methodological contribution even with short proofs. If all realistic sets make p-values uninformative, the result may remain a useful negative finding or diagnostic note. Either outcome should be determined by evidence rather than an innovation-size threshold.

### Gaps
- I cannot certify an absolute first-publication claim for the exact construction.
- The present illustration demonstrates information value under constructed sets, not the feasibility of obtaining informative, trustworthy graphs in the motivating Rajasthan data.
- Nothing in this inference-focused review establishes new graph-theoretic priority for the cycle criterion, component formula, or constant-objective characterizations; those are assessed separately.
