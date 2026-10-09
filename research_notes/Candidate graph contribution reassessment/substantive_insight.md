# Substantive contribution of candidate graphs for causal inference

## What substantive insight is already explicit in the closest literature?

### Takeaway

“Accuracy is not enough,” “some identity errors are harmless,” and “the query may be determined before identities are determined” are established ideas. The current note sharpens them for a causal contrast, but should not claim discovery of these principles.

### Cited Findings

- Wortman and Reiter, *Simultaneous Record Linkage and Causal Inference with Propensity Score Subclassification*, §3.1, printed pp. 6–7, explicitly exchange two treated outcomes within a subclass and obtain exactly the same difference-in-means estimator. They immediately note that regression adjustment can change unless the covariates coincide. §3.2 contrasts errors that cross treatment status. §4, pp. 9–10, chooses accepted links for treatment-effect performance rather than identity accuracy alone. Their formulation therefore already teaches that the causal consequences of errors depend on where the errors occur; accepting only certain links can unnecessarily lose precision. The paper studies particular probabilistic-error assumptions and case-selection algorithms, not the graph-wide robust test in the current note. [Author full text](https://arxiv.org/pdf/1709.03631).
- Turkcapar and Krishnan, *Quantifying Uncertainty in Aggregate Queries over Integrated Datasets*, §§3.1–3.3 and Proposition 3.1, turn candidate pairs into constrained weighted-matching extrema; §4.4 uses query-specific interval width to describe uneven uncertainty. Their object is already the possible downstream answers over feasible integrated datasets. The treatment contrast is a signed weighted aggregate. One must use the correct perfect-matching constraints for signed weights; this is not a claim that every printed formulation in their one-to-many treatment transfers literally. [Full text](https://arxiv.org/html/2309.05178v1).
- Altwaijry, Kalashnikov, and Mehrotra, *Query-Driven Approach to Entity Resolution*, §5.4, printed p. 1852, Definition 8 and Theorems 1–2, formalize when an unresolved identity edge can be ignored without changing a query answer. Their graph is a deduplication/co-reference graph, and their queries are selections with aggregation semantics, not causal treatment contrasts. Nevertheless, functional resolution without identity resolution is an explicit prior principle, including structural certificates and a way to avoid unnecessary resolution work. [VLDB full text](https://www.vldb.org/pvldb/vol6/p1846-altwaijry.pdf).
- Hall and Fienberg, *Valid Statistical Inference on Automatically Matched Files*, printed p. 2, explicitly propose confidence sets of bipartite matchings and optimization of downstream statistics over those sets. They mention regression coefficient extrema and a compact constraint representation. Their own permutation test concerns linkage under a measurement model; it is not Fisher’s treatment-assignment test. The broad confidence-set propagation principle predates the present project. [Author full text](https://www.cs.cmu.edu/~rjhall/linkage.pdf).
- Jeffery, Franklin, and Halevy already formulate ordering candidate confirmations by value of information for query-result quality. This establishes task-aware review as an older research direction; I did not obtain the full paper in this run, so do not use it to assert the exact causal-width criterion was previously derived. [Author publication page](https://research.google/pubs/pay-as-you-go-user-feedback-for-dataspace-systems/).
- A 2024 conference presentation by Bor and Lauren explicitly treats the effects of linkage error as depending on linkage-network structure and downstream analysis; slides 6–10 introduce the network simulation and slides 19–21 discuss consequences. This concerns repeated-record clustering and epidemiological summaries, not the proposed perfect-bijection graph test. It reinforces that structural consequences are a known general concern, not an exact mathematical antecedent. [Primary presentation](https://www.wce2024.org/wp-content/uploads/2024/10/Jacob-The-fundamental-role-of-linkage-uncertainty-in-epidemiological-analysis-of-big-data.pdf).

### Inferences

- None of these sources alone supplies the current causal procedure in its exact stated form. Equally, naming a causal estimand does not make a generic weighted-matching calculation a newly discovered statistical principle.
- The weight-difference times outcome-difference identity is a useful explanation of the mechanism. Wortman–Reiter already provides its central causal special case. A general algebraic identity is a clearer presentation, but the identity alone is a weak originality claim.
- The strongest distinction is support information rather than an average error mechanism: the graph lets an analyst exclude particular reconstructions, and determine the conclusion across everything still possible. This is an actionable specialization of Hall–Fienberg and robust causal-testing ideas, not a new justification for confidence-set propagation.
- Avoid claiming that existing causal linkage work simply targets high precision or assumes unconditional independence between linkage quality and potential outcomes. The closest papers are more sophisticated than that.

### Gaps

- I did not locate the exact same-accuracy, same-degree, same-number-of-matchings causal comparison in the reviewed sources. Absence of that example is not by itself an originality result.
- Query-driven ER and optimization contain extensive mathematical literature. The coordinator’s separate mathematical review should control claims about priority of the cycle and constant-objective characterizations.
- Search cutoff was 2026-10-08. Exact first priority of this causal specialization cannot be certified by these searches.

## What does the current work add beyond putting familiar ideas next to each other?

### Takeaway

It supplies a concrete causal decision that the nearest causal record-linkage papers do not operationalize: **can the sharp no-effect null be rejected for every feasible identity reconstruction, without selecting a linkage or specifying probabilities over linkages?** The implementation answers that question and returns a reconstruction attaining the worst case. That is a real technical specialization; whether it supports a research paper depends on the practical evidence and how narrowly the contribution is described.

### Cited Findings

- The local note defines a common donor pool, bijections, an accepted linkage, an at-most-K discrepancy budget, and a candidate graph. Its accuracy-only comparator preserves all those restrictions except the graph. It therefore avoids comparison with an artificially weak model that invents new donor outcomes or permits donor duplication. [Current formalization, §1](/Users/soodoku/Documents/GitHub/causal_linkage/research/graph-information.md).
- Under complete random assignment and full bijections, the note proves that each reconstructed outcome vector has the same unadjusted randomization reference law. Therefore the maximum two-sided p-value is the reference tail at the smallest attainable absolute treatment contrast. The implementation optimizes over feasible assignments, keeps gaps in the attainable statistic set, and returns an attaining matching. Its uncertainty-containment adjustment is conditional on a valid supplied bound; the program does not learn that bound. [Current formalization, §4](/Users/soodoku/Documents/GitHub/causal_linkage/research/graph-information.md).
- The fixed example keeps the accepted linkage, its actual 75% accuracy, graph degree, and number of admissible reconstructions the same. The robust p-values are 2/70 and 34/70 because the feasible donor reallocations differ. This isolates alignment of admissible identity changes with treatment and outcome values, beyond the amount of ambiguity. [Current example, §3](/Users/soodoku/Documents/GitHub/causal_linkage/research/graph-information.md).
- Across all 70 assignments in the accompanying design, benefits are not universally large. At effects 2 and 4 the oracle rejects every time, each candidate graph rejects 6/70 times, and accuracy-only never rejects at 5%. The two graphs need not be ordered at other levels. These results support an information gain, not a claim of generally recovered power. [Exhaustive results](/Users/soodoku/Documents/GitHub/causal_linkage/results/graph-information/report.md).

### Inferences

- This is more than juxtaposition because the graph is made an input to an executable causal decision rule, with a worst-case witness and an exact design benchmark. A researcher can answer “does my conclusion require deciding this identity?” and inspect the reconstruction that defeats it. Wortman–Reiter’s estimate-oriented pair selection does not return this certificate.
- It is still a narrow contribution. Hall–Fienberg already says to propagate matching sets into statistics; Heng–Shaw supplies closely related adversarial randomization-testing machinery, as examined by the coordinator’s other researcher. The original connection, if claimed, is their explicit specialization to identity-conserving candidate graphs and the resulting attainable treatment-contrast analysis. It should be assessed as an application of established theory, not as a new inferential principle.
- The exact same-summary example is a particularly clean teaching device and useful controlled experiment. It makes a known qualitative point unusually transparent. Novel numbers and a new toy example do not independently establish a research contribution.
- Current evidence is enough to call this a completed technical specialization and a candidate applied-methods contribution. I would not yet assert a demonstrated substantive advance in research practice: all new randomization results use eight units and engineered truth-containing graphs.
- My independent judgment is to continue the focused investigation rather than dismiss it for lacking a large theorem. However, the present evidence supports “we develop and evaluate a graph-constrained sensitivity analysis for randomized studies” more strongly than “we uncover a previously unrecognized source of causal information.”
- This distinction is not a demand for grand innovation. A modest original application can be a contribution. It should still demonstrably solve an actual inferential decision better than available analysis with the same information.

### Gaps

- The code’s current regime assumes known anchor assignment and a complete donor census. Unknown overlap, covariates moved by linkage, changing design weights, and blocked assignment are not covered by the common-null-law shortcut.
- The graph and accuracy budget are assumed to contain the truth, or accompanied by a supplied failure bound. False confidence from candidate omission remains possible.
- The current research did not establish a new optimal review policy. The diagnostic can identify irrelevant components, but a claim that its review allocation improves causal inference requires an actual allocation comparison.

## What limited addition would establish a stronger contribution?

### Takeaway

The next discriminating evidence is one credible causal linkage experiment or application showing that retaining candidate support changes a real analysis or audit decision. A new general theory of all linkage errors is unnecessary. The evidence must show why a researcher should keep and use the graph instead of retaining only an accepted matching and error-rate summary.

### Cited Findings

- The current exhaustive design fixes small graphs selected to expose alignment with potential outcomes; it explicitly disclaims an identifier-learning mechanism. The note’s next proposed target is identity review that resolves or expands consequential graph components. [Current formalization, §§5–6](/Users/soodoku/Documents/GitHub/causal_linkage/research/graph-information.md).
- The existing Rajasthan ranges use actual candidate restrictions and fixed regression weights, but the note states that historical assignment support and credible reconstruction containment are not established. Thus those ranges cannot currently validate the new exact causal test. [Current formalization, §6](/Users/soodoku/Documents/GitHub/causal_linkage/research/graph-information.md).

### Inferences

- A bounded strengthening is to use a randomized dataset with known true identities, generate or reuse genuinely ambiguous identifier candidates, and compare the same accepted linkage, the same donor pool, and the same error-budget information with and without candidate restrictions. Report how often the graph turns an inconclusive result into a robust conclusion, and how often it does not.
- Preserve the distinction between two questions: what information the graph would buy if valid, and whether the actual graph-generation procedure validly retains truth. An oracle truth-containing comparison answers the first. Candidate omission and budget sensitivity should answer the second without claiming calibration that has not been supplied.
- If review is the proposed practical contribution, run a small fixed-budget comparison: ambiguous-record review versus review of candidate components that can actually change the contrast or the robust test. Record both improvement and cases where the graph criterion is unhelpful. This would establish a consequence of structural analysis rather than just repeat the slogan that review should be task-aware.
- One well-chosen real or realistic example can strengthen a focused note. No need to expand into unknown overlap, arbitrary confounder error, and a general validation theory simultaneously.
- The contribution should survive deletion of the sentence “accuracy rates are insufficient.” What remains should be a usable input/output procedure, a causal validity statement, and evidence that candidate structure changes the decision at an acceptable information and review cost. If that remainder is negligible outside the engineered example, the work is better framed as a tutorial or synthesis.

### Gaps

- Whether realistic identifier ambiguity is often concentrated enough within equal-weight or similar-outcome regions to yield informative robust tests remains unanswered.
- Whether the review criterion delivers more value than a strong existing query-aware strategy is untested.
- Publication suitability is an editorial judgment. The research supports a plausible modest contribution path, not guaranteed acceptance or a universal priority claim.
