# Applied studies of sensitivity to record linkage

## Have researchers actually shown estimates and significance changing?

### Takeaway
Yes. Applied comparisons show changed coefficients, interval widths, significance, and even the direction of comparisons against external benchmarks. These precedents usually compare linkage procedures or thresholds, with changes in ascertainment or sample membership; they are not sharp bounds over fixed-cohort feasible identity assignments.

### Cited Findings
- **Harron, Doidge, Knight, Gilbert, Goldstein, Cromwell, and van der Meulen (2017), “A guide to evaluating linkage quality for the analysis of linked data,” International Journal of Epidemiology 46(5):1699–1710.** Table 3 compares English mother–baby records under gold-standard, original probabilistic, high-threshold probabilistic, and deterministic linkage. The adjusted odds ratio for **neonatal survival to discharge, mothers with delivery risk factors versus without**, is respectively **0.40 (95% CI 0.17–0.95), p=.039; 0.42 (.18–.98), p=.044; 0.35 (.15–.79), p=.011; 0.52 (.22–1.25), p=.143**. The deterministic sample links less than half of records: the significance change is importantly a loss of precision, not a reversal in estimated direction. For **delivery risk factors, Black versus White ethnicity**, gold-standard OR **.98 (.88–1.09), p=.700** becomes **.80 (.66–.96), p=.017** under deterministic linkage. The authors diagnose selection from differential missed matches. This is an actual threshold/procedure sensitivity analysis, but changes sample membership. [Full paper, Table 3](https://pmc.ncbi.nlm.nih.gov/articles/PMC5837697/)

- **Moore, Gidding, Law, and Amin (2016), “Poor record linkage sensitivity biased outcomes in a linked cohort analysis,” Journal of Clinical Epidemiology 75:70–77.** Two recruited cohorts (557 HIV-positive and 1,325 HIV-negative men) are linked to hospital records. For HIV-positive men, hospitalization standardized incidence ratio versus the general male population is **1.45 (1.33–1.59)** with probabilistic linkage but **.46 (.37–.58)** with deterministic linkage. For HIV-negative men, it changes from **.72 (.67–.78)** to **.29 (.24–.35)**. Deterministic recall is **34.67%**, with disproportionate missing links among poorer socioeconomic and health groups. These are fixed recruited cohorts but different outcome-event ascertainment; this is not one-to-one rematching of a small number of nearly tied identities. Probabilistic linkage is the reference standard, not incontrovertible ground truth. [Author manuscript and publisher DOI](https://pmc.ncbi.nlm.nih.gov/articles/PMC4916010/)

### Inferences
- Prior evidence plainly establishes that linkage choices can affect statistical conclusions. It does not establish that a tiny number of credible near-tie substitutions would overturn the Rajasthan estimate.
- A p-value crossing .05 may arise mainly from sample size and precision; that should be separated from substantial coefficient movement.

### Gaps
- These two studies do not certify best/worst coefficient or p-value ranges over an identity-constrained feasible graph.

## Do historical linkage studies show the same sensitivity, or robustness?

### Takeaway
Both. Historical economics explicitly studies downstream regression sensitivity. Some studies find important attenuation, others report relatively stable substantive conclusions.

### Cited Findings
- **Bailey, Cole, Henderson, and Massey (2020), “How Well Do Automated Linking Methods Perform? Lessons from US Historical Data,” Journal of Economic Literature 58(4):997–1044.** The final publisher abstract reports intergenerational-income-elasticity attenuation up to **29%** from linkage methods, and more under common variations. The accessible PMC manuscript instead reports **20%**, so versions must not be combined silently. Its Figure 7 discussion gives LIFE-M elasticity **.24** versus **.19–.11** for variants that weight ambiguous ties; removing links deemed incorrect yields elasticities around **.23** across algorithms. Phonetic cleaning, common-name inclusion, and tie treatment are examined. Both false links and sample composition change; this is not a fixed-cohort graph optimization. Human-reviewed links serve as a benchmark, with the usual uncertainty about benchmark error. [Final publisher abstract](https://www.aeaweb.org/articles?id=10.1257/jel.20191526); [accessible manuscript, Figure 7 and Section VI.C](https://pmc.ncbi.nlm.nih.gov/articles/PMC8294155/)

- **Abramitzky, Boustan, Eriksson, Feigenbaum, and Pérez (2021), “Automated Linking of Historical Data,” Journal of Economic Literature 59(3):865–918.** The final abstract concludes that parameters are similar across several plausible analyses and linkage methods. The author-hosted June 2020 manuscript's Section 4.1/Figure 7 estimates father–son earnings elasticities from Iowa 1915 to US 1940: estimates range **.15–.20**, with the hand-linked estimate's 95% interval containing every automated estimate. Section 4.2/Table 5 finds the same US-versus-Norway occupational-mobility ordering across methods. The authors explicitly recommend rerunning analyses on alternative samples produced by multiple linkage algorithms. Hence sensitivity checking is recommended practice, and dramatic sensitivity is not universal. Again, these compare separately linked samples, not certified extrema. [Final publisher abstract](https://www.aeaweb.org/articles?id=10.1257/jel.20201599); [author-hosted manuscript](https://ranabr.people.stanford.edu/sites/g/files/sbiybj26066/files/media/file/automated_linking_jun9_2020.pdf)

### Inferences
- The defensible distinction for the present project is the precise feasible-set question, if established, rather than the observation that linkage choices change inference.
- The contrast between Bailey and Abramitzky is useful evidence of setting and method dependence, not a contradiction that can be settled by one headline error rate.

### Gaps
- I did not inspect the final typeset Bailey Figure 7, so use final abstract's 29% for the final-publication headline and explicitly label detailed PMC numbers as manuscript-version results.

## What is the closest causal-inference lead?

### Takeaway
There is already directly relevant work about administrative linkage changing treatment-effect estimation and power in randomized experiments. The parent research stream should assess its exact overlap.

### Cited Findings
- **Tahamont, Jelveh, Chalfin, Yan, and Hansen**, working paper “Administrative Data Linking and Statistical Power Problems in Randomized Experiments” (2019), published as **“Dude, Where’s My Treatment Effect? Errors in Administrative Data Linking and the Destruction of Statistical Power in Randomized Experiments”** (Journal of Quantitative Criminology 37, 2021). The NBER abstract explicitly derives power consequences of linking errors and studies how strict exact matching loses power and probabilistic methods recover it. This lead is directly about randomized treatment effects, not just correlational historical mobility. I verified the abstract and publication PDF identity but did not inspect its empirical tables. [NBER](https://www.nber.org/papers/w25657); [published author-hosted PDF](https://ccjs.umd.edu/sites/ccjs.umd.edu/files/pubs/Tahamont2021_Article_DudeWhereSMyTreatmentEffectErr.pdf)

### Inferences
- It is untenable to position “linkage affects causal estimates, standard errors, and significance” itself as an uncovered observation.

### Gaps
- No claim here that these applied studies establish novel graph-constrained worst-case p-value inference, or that their sensitivity procedures are directly equivalent to the present graph optimization.
