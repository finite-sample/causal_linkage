from pathlib import Path

import numpy as np
import pandas as pd
from scipy import sparse
from scipy.sparse.linalg import lsqr
from scipy.stats import beta

r = Path(__file__).resolve().parents[3]
q = r.parent / "quota_spending"
a = pd.read_parquet(q / "data/raj/mnrega_elex_raj_05_10.parquet")
d = pd.read_parquet(q / "data/mnrega/mnrega_r6.parquet")
e = pd.read_parquet(r / "application/results/candidate_graph.parquet")
w = pd.read_parquet(r / "application/results/lottery/witnesses.parquet")
cols = [f"total_comp_project_{y}" for y in range(2011, 2015)]
d["Y"] = d[cols].sum(axis=1)
d = d.set_index("state_key", verify_integrity=True)
a = a.set_index("key_2010", verify_integrity=True)
assert len(a) == 4355
rng = np.random.default_rng(91872026)
B = 19999
res = []
detail = []
design = []
for yr in [2005, 2010]:
    other = 2010 if yr == 2005 else 2005
    z = a[f"female_res_{yr}"].to_numpy(float)
    sf = [
        f"dist_name_new_{yr}",
        f"samiti_name_new_{yr}",
        f"caste_res_{yr}",
        f"female_res_{other}",
    ]
    assert not a[sf].isna().any().any()
    strata = pd.factorize(pd.MultiIndex.from_frame(a[sf]))[0]
    ns = np.bincount(strata)
    ms = np.bincount(strata, weights=z)
    pr = ms[strata] / ns[strata]
    v = z - pr
    den = np.sum(v * v)
    wt = v / den
    fixed = sparse.coo_matrix(
        (np.ones(len(a)), (np.arange(len(a)), strata)), shape=(len(a), len(ns))
    ).tocsr()
    X = sparse.hstack([sparse.csr_matrix(z[:, None]), fixed]).tocsr()
    names = ["accepted", "budget_43_minimum", "budget_43_maximum"]
    maps = []
    ys = []
    for name in names:
        ww = w[(w.year == yr) & (w.linkage == name)].set_index("source_id").loc[a.index]
        ids = ww.target_id.to_numpy()
        y = d.loc[ids, "Y"].to_numpy(float)
        assert len(set(ids)) == len(a)
        assert np.max(np.abs(wt - ww.weight.to_numpy())) < 1e-12
        assert np.array_equal(y, ww.outcome.to_numpy())
        legal = e[(e.source_eligible) & (e.target_eligible) & (e.distance < 0.1)]
        eset = set(zip(legal.source_id, legal.target_id))
        assert all((i, j) in eset for i, j in zip(a.index, ids))
        maps.append(ids)
        ys.append(y)
        lm = lsqr(X, y, atol=1e-12, btol=1e-12, iter_lim=10000)
        assert abs(lm[0][0] - wt @ y) < 1e-7
    Y = np.column_stack(ys)
    observed = wt @ Y
    ref = np.zeros((B, len(names)))
    exactvar = np.zeros(len(names))
    for g, n in enumerate(ns):
        ii = np.flatnonzero(strata == g)
        m = int(ms[g])
        if m == 0 or m == n:
            continue
        # Independent direct permutations, without enumeration of subsets.
        zz = rng.permuted(np.broadcast_to(z[ii], (B, n)).copy(), axis=1)
        ref += (zz - m / n) @ Y[ii, :] / den
        exactvar += m * (n - m) / n * np.var(Y[ii, :], axis=0, ddof=1) / den**2
    design.append(
        dict(
            year=yr,
            N=len(a),
            strata=len(ns),
            informative_strata=np.sum((ms > 0) & (ms < ns)),
            informative_N=np.sum((pr > 0) & (pr < 1)),
            denominator=den,
            max_abs_weight=max(abs(wt)),
            outcome_mean=Y[:, 0].mean(),
            outcome_sd=Y[:, 0].std(ddof=1),
            outcome_median=np.median(Y[:, 0]),
            outcome_p99=np.quantile(Y[:, 0], 0.99),
            outcome_max=max(Y[:, 0]),
        )
    )
    for j, name in enumerate(names):
        success = np.sum(np.abs(ref[:, j]) >= abs(observed[j]) - 1e-10)
        lo = 0 if success == 0 else beta.ppf(0.025, success, B - success + 1)
        hi = 1 if success == B else beta.ppf(0.975, success + 1, B - success)
        changes = maps[j] != maps[0]
        dy = Y[:, j] - Y[:, 0]
        delta = wt * dy
        res.append(
            dict(
                year=yr,
                map=name,
                coef=observed[j],
                p=(success + 1) / (B + 1),
                mc95lo=lo,
                mc95hi=hi,
                exceed=success,
                nullmean=ref[:, j].mean(),
                nullsd=ref[:, j].std(ddof=1),
                nullsd_exact=np.sqrt(exactvar[j]),
                changed=int(changes.sum()),
                new_donors=len(set(maps[j]) - set(maps[0])),
                coef_delta=delta.sum(),
                changed_mean_abs_dY=(
                    np.mean(np.abs(dy[changes])) if changes.any() else 0
                ),
                changed_sum_abs_dY=np.sum(abs(dy[changes])),
                max_abs_contribution=max(abs(delta)),
                top5_abs_contribution=np.sort(abs(delta))[-5:].sum(),
                positive_changes=int(np.sum((delta > 0) & changes)),
                negative_changes=int(np.sum((delta < 0) & changes)),
            )
        )
        if j:
            dd = pd.DataFrame(
                dict(
                    year=yr,
                    map=name,
                    source_id=a.index,
                    old_target=maps[0],
                    new_target=maps[j],
                    z=z,
                    weight=wt,
                    old_y=Y[:, 0],
                    new_y=Y[:, j],
                    delta=delta,
                    stratum=strata,
                )
            )
            detail.append(dd[changes].sort_values("delta"))
out = Path(__file__).resolve().parent
pd.DataFrame(res).to_csv(out / "quota_statistical_results.csv", index=False)
pd.DataFrame(design).to_csv(out / "quota_statistical_design.csv", index=False)
pd.concat(detail).to_csv(out / "quota_statistical_changed.csv", index=False)
print(pd.DataFrame(design).to_string(index=False))
print(pd.DataFrame(res).to_string(index=False))
