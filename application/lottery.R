args <- commandArgs(trailingOnly = TRUE)
source_root <- normalizePath(if (length(args)) args[1] else "../quota_spending", mustWork = TRUE)
draws <- if (length(args) > 1) as.integer(args[2]) else 19999L
source("R/core.R")
source("R/lottery.R")
out <- "application/results/lottery"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
source_path <- file.path(source_root, "data/raj/mnrega_elex_raj_05_10.parquet")
target_path <- file.path(source_root, "data/mnrega/mnrega_r6.parquet")
graph_path <- "application/results/candidate_graph.parquet"
source_fields <- c("key_2010", "state_key", unlist(lapply(c(2005, 2010), function(year) {
  paste0(c("female_res_", "caste_res_", "dist_name_new_", "samiti_name_new_"), year)
})))
anchors <- as.data.frame(arrow::read_parquet(
  source_path, col_select = dplyr::all_of(source_fields)
))
donors <- as.data.frame(arrow::read_parquet(target_path,
  col_select = c("state_key", paste0("total_comp_project_", 2011:2014))
))
edges <- as.data.frame(arrow::read_parquet(graph_path))
edges <- edges[
  edges$source_eligible & edges$target_eligible & edges$distance < .1 &
    edges$source_id %in% anchors$key_2010,
]
donors <- donors[donors$state_key %in% edges$target_id, ]
donors$y <- rowSums(donors[paste0("total_comp_project_", 2011:2014)], na.rm = TRUE)
edges$i <- match(edges$source_id, anchors$key_2010)
edges$j <- match(edges$target_id, donors$state_key)
accepted <- match(anchors$state_key, donors$state_key)
edge_keys <- paste(edges$i, edges$j)
stopifnot(
  !anyNA(accepted), !anyDuplicated(accepted), !anyNA(edges$i), !anyNA(edges$j),
  all(paste(seq_len(nrow(anchors)), accepted) %in% edge_keys)
)
blocks <- split(seq_len(nrow(edges)), edges$block_key)

extreme_maps <- function(weights) {
  maps <- list(minimum = integer(nrow(anchors)), maximum = integer(nrow(anchors)))
  for (block in blocks) {
    e <- edges[block, ]
    sources <- unique(e$i)
    targets <- unique(e$j)
    a <- matrix(0, length(sources) + length(targets), nrow(e))
    a[cbind(match(e$i, sources), seq_len(nrow(e)))] <- 1
    a[cbind(length(sources) + match(e$j, targets), seq_len(nrow(e)))] <- 1
    cost <- weights[e$i] * donors$y[e$j]
    for (which_end in names(maps)) {
      fit <- lpSolve::lp(
        if (which_end == "minimum") "min" else "max", cost, a,
        c(rep("=", length(sources)), rep("<=", length(targets))), rep(1, nrow(a))
      )
      stopifnot(fit$status == 0, max(abs(fit$solution - round(fit$solution))) < 1e-6)
      chosen <- which(fit$solution > .5)
      maps[[which_end]][e$i[chosen]] <- e$j[chosen]
    }
  }
  maps
}

summaries <- witnesses <- strata_tables <- extremes <- budget_extremes <- list()
budgets <- floor(nrow(anchors) * c(.001, .005, .01, .05, .1))
family_size <- 2L * (4L + 3L * length(budgets))
for (year in c(2005, 2010)) {
  other <- if (year == 2005) 2010 else 2005
  z <- anchors[[paste0("female_res_", year)]]
  strata_fields <- anchors[c(
    paste0("dist_name_new_", year), paste0("samiti_name_new_", year),
    paste0("caste_res_", year), paste0("female_res_", other)
  )]
  stopifnot(!anyNA(strata_fields))
  strata <- do.call(paste, c(strata_fields, sep = "|"))
  design <- conditional_lottery(z, strata)
  endpoints <- extreme_maps(design$weights)
  near_zero <- blend_linkages(design$weights, donors$y, endpoints$minimum, endpoints$maximum)
  maps <- c(list(accepted = accepted), endpoints, list(near_zero = near_zero))
  for (budget in budgets) {
    maps[[paste0("budget_", budget, "_minimum")]] <- budget_linkage(
      design$weights, donors$y, accepted, endpoints$minimum, budget, "min"
    )
    maps[[paste0("budget_", budget, "_maximum")]] <- budget_linkage(
      design$weights, donors$y, accepted, endpoints$maximum, budget, "max"
    )
    blended <- lapply(c("minimum", "maximum"), function(which_end) {
      blend_linkages(design$weights, donors$y, accepted,
                     maps[[paste0("budget_", budget, "_", which_end)]])
    })
    best <- which.min(vapply(blended, function(map) {
      abs(sum(design$weights * donors$y[map]))
    }, numeric(1)))
    maps[[paste0("budget_", budget, "_near_zero")]] <- blended[[best]]
  }
  outcomes <- vapply(maps, function(map) {
    stopifnot(
      all(map > 0), !anyDuplicated(map),
      all(paste(seq_along(map), map) %in% edge_keys)
    )
    donors$y[map]
  }, numeric(nrow(anchors)))
  observed <- drop(crossprod(design$weights, outcomes))
  final_seed <- 80312026 + year
  set.seed(final_seed)
  reference <- lottery_reference(outcomes, z, strata, draws)
  summary <- lottery_tail_summary(reference, observed, family_size = family_size)
  summary$year <- year
  summary$seed <- final_seed
  summary$linkage <- names(maps)
  summary$changed_links <- vapply(maps, function(map) sum(map != accepted), integer(1))
  summary$error_budget <- rep(NA_real_, nrow(summary))
  budget_rows <- grepl("^budget_", summary$linkage)
  summary$error_budget[budget_rows] <- as.numeric(sub(
    "^budget_([0-9]+)_.*$", "\\1", summary$linkage[budget_rows]
  ))
  summary$error_budget[summary$linkage == "accepted"] <- 0
  stopifnot(all(summary$changed_links[budget_rows] <= summary$error_budget[budget_rows]))
  summary$total_anchors <- nrow(anchors)
  summary$informative_anchors <- sum(design$weights != 0)
  summary$denominator <- design$denominator
  summaries[[as.character(year)]] <- summary
  extremes[[as.character(year)]] <- data.frame(
    year, statistic_lower = observed["minimum"], statistic_upper = observed["maximum"],
    p_min_lower = 0, p_min_upper = min(summary$p_upper),
    p_max_lower = max(summary$p_lower), p_max_upper = 1,
    family_confidence = .95
  )
  budget_extremes[[as.character(year)]] <- do.call(rbind, lapply(c(0, budgets), function(k) {
    applicable <- summary$changed_links <= k
    data.frame(year, error_budget = k, error_fraction = k / nrow(anchors),
               p_min_lower = if (k == 0) summary$p_lower[summary$linkage == "accepted"] else 0,
               p_min_upper = min(summary$p_upper[applicable]),
               p_max_lower = max(summary$p_lower[applicable]),
               p_max_upper = if (k == 0) summary$p_upper[summary$linkage == "accepted"] else 1)
  }))
  for (name in names(maps)) {
    witnesses[[length(witnesses) + 1L]] <- data.frame(
      year, linkage = name, source_id = anchors$key_2010,
      target_id = donors$state_key[maps[[name]]], weight = design$weights,
      outcome = donors$y[maps[[name]]]
    )
  }
  strata_rows <- lapply(names(design$groups), function(name) {
    ids <- design$groups[[name]]
    data.frame(year, stratum = name, n = length(ids), treated = sum(z[ids]),
               informative = length(unique(z[ids])) == 2)
  })
  strata_tables[[as.character(year)]] <- do.call(rbind, strata_rows)
  cat("Finished lottery year ", year, "\n", sep = "")
  print(summary[c("linkage", "statistic", "p_mc", "p_lower", "p_upper", "changed_links")],
        row.names = FALSE)
}
summary <- do.call(rbind, summaries)
extremes <- do.call(rbind, extremes)
write.csv(summary, file.path(out, "witness_p_values.csv"), row.names = FALSE)
write.csv(extremes, file.path(out, "p_extrema_bounds.csv"), row.names = FALSE)
write.csv(do.call(rbind, budget_extremes), file.path(out, "budget_p_extrema_bounds.csv"),
          row.names = FALSE)
write.csv(do.call(rbind, strata_tables), file.path(out, "strata.csv"), row.names = FALSE)
arrow::write_parquet(do.call(rbind, witnesses), file.path(out, "witnesses.parquet"))
paths <- c(source_path, target_path, graph_path)
write.csv(data.frame(
  path = normalizePath(paths),
  sha256 = vapply(paths, digest::digest, character(1), algo = "sha256", file = TRUE)
), file.path(out, "source_manifest.csv"), row.names = FALSE)
writeLines(
  trimws(capture.output(sessionInfo()), which = "right"), file.path(out, "sessionInfo.txt")
)
lines <- c(
  "# Rajasthan under an assumed reservation lottery", "",
  "The [candidate-set audit](../linkage-stress-audit/report.md) finds that this broad",
  "graph admits weak GP-name alternatives because its distance includes shared",
  "district and block names. Tighter name rules sharply reduce coefficient sensitivity.",
  "The dramatic small-budget shifts below require that broad candidate-set assumption.",
  "",
  "Assignment is assumed uniform within district, Samiti, current-cycle caste",
  "category, and other-cycle reservation status, fixing each stratum's treated count.",
  "This assumption includes exchangeability within the retained cohort.", "",
  "Outcome: recorded completed projects summed over 2011–2014, with the existing",
  "missing-as-zero convention. The statistic is the stratum fixed-effect slope,",
  "not the earlier additive OLS coefficient. Pure-treatment strata carry zero weight.", "",
  "Each row is a feasible linkage evaluated against its own lottery distribution.",
  "The endpoint maps optimize the statistic; they do not necessarily optimize p.",
  "The near-zero map mixes whole alternating components of the endpoint maps.", ""
)
budget_bounds <- do.call(rbind, budget_extremes)
lines <- c(lines,
  "| Year | Maximum changed identities | Upper bound on minimum p | Lower bound on maximum p |",
  "|---:|---:|---:|---:|",
  sprintf("| %d | %d | %.6f | %.6f |", budget_bounds$year, budget_bounds$error_budget,
          budget_bounds$p_min_upper, budget_bounds$p_max_lower), "",
  "All evaluated witnesses satisfying a cap contribute, including a map discovered",
  "in a larger-budget search that ultimately changes fewer identities.", "",
  "| Year | Linkage | Statistic | MC p | Simultaneous MC interval | Changed links |",
  "|---:|:---|---:|---:|:---|---:|"
)
lines <- c(lines, sprintf(
  "| %d | %s | %.4f | %.6f | [%.6f, %.6f] | %d |",
  summary$year, summary$linkage, summary$statistic, summary$p_mc,
  summary$p_lower, summary$p_upper, summary$changed_links
), "", sprintf(
  "Each year uses %d independent lottery draws. Intervals have at least 95%% joint", draws
), sprintf(
  "Monte Carlo coverage across all %d witness probabilities (Bonferroni-adjusted", family_size
),
"Clopper–Pearson). The plus-one MC p-value is not an exact enumeration probability.", "",
"| Year | Bounds on minimum p | Bounds on maximum p |",
"|---:|:---|:---|")
lines <- c(lines, sprintf(
  "| %d | [%.6f, %.6f] | [%.6f, %.6f] |", extremes$year,
  extremes$p_min_lower, extremes$p_min_upper, extremes$p_max_lower, extremes$p_max_upper
), "", "These bound the global extrema with the same Monte Carlo confidence; they are",
"not a computed exact p-value range. A small feasible p shows linkage sensitivity,",
"not robust rejection. A large feasible p rules out uniform rejection across the",
"candidate set, subject to the reported Monte Carlo uncertainty. It does not prove",
"a small or zero treatment effect. Witnesses chosen using observed data are not",
"individually valid post-selection causal tests.", "",
"All selected anchors must match one eligible donor, with no donor reuse. Candidate",
"distance is below 0.1. Budget rows additionally cap changed accepted identities;",
"they optimize a switchable-component subset of the graph. Unbudgeted endpoint",
"rows allow all feasible graph links. Accepted links",
"and prior election-history linkage remain assumptions, not independently validated",
"truth. These results quantify sensitivity conditional on that reconstruction set.", "",
"See [design and interpretation](../../lottery-design.md) and",
"[budget-specific p extrema bounds](budget_p_extrema_bounds.csv).")
writeLines(lines, file.path(out, "report.md"))
