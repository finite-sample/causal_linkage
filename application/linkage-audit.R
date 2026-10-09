suppressPackageStartupMessages(library(dplyr))
args <- commandArgs(trailingOnly = TRUE)
root <- normalizePath(".")
quota <- normalizePath(if (length(args)) args[1] else "../quota_spending")
out <- file.path(root, "application/results/linkage-stress-audit")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
a <- as.data.frame(arrow::read_parquet(file.path(quota, "data/raj/mnrega_elex_raj_05_10.parquet"),
  col_select = c(
    "key_2010", "gp_new_2010", "state_key", "match_name.x", "female_res_2005",
    "female_res_2010", "mnrega_block_name", "dist_name_new_2010"
  )
))
d <- as.data.frame(arrow::read_parquet(file.path(quota, "data/mnrega/mnrega_r6.parquet"),
  col_select = c(
    "state_key", "panchayat", "district", "block",
    paste0("total_comp_project_", 2011:2014)
  )
))
t <- read.csv(file.path(quota, "data/mnrega/raj_mnrega_transliteration.csv"))
d$name <- t$chat_gpt_fin[match(d$panchayat, t$hindi)]
d$name[is.na(d$name)] <- d$panchayat[is.na(d$name)]
normalize <- function(x) {
  x <- stringi::stri_trans_tolower(stringi::stri_trans_general(x, "Latin-ASCII"))
  gsub("[[:punct:][:space:]]", "", x)
}
d$name_normalized <- normalize(d$name)
d$y <- rowSums(d[paste0("total_comp_project_", 2011:2014)], na.rm = TRUE)
d$missing_years <- rowSums(is.na(d[paste0("total_comp_project_", 2011:2014)]))
g <- as.data.frame(arrow::read_parquet(
  file.path(root, "application/results/candidate_graph.parquet")
))
g <- g[g$source_eligible & g$target_eligible & g$distance < .1 & g$source_id %in% a$key_2010, ]
g$rank <- ave(g$distance, g$source_id, FUN = function(x) rank(x, ties.method = "min"))
w <- as.data.frame(arrow::read_parquet(
  file.path(root, "application/results/lottery/witnesses.parquet")
))
rows <- summaries <- list()
for (year in c(2005, 2010)) {
  for (kind in c("budget_43_minimum", "budget_43_maximum")) {
    m <- w[w$year == year & w$linkage == kind, ]
    ai <- match(m$source_id, a$key_2010)
    old <- match(a$state_key[ai], d$state_key)
    new <- match(m$target_id, d$state_key)
    changed <- m$target_id != a$state_key[ai]
    oe <- match(paste(m$source_id, a$state_key[ai]), paste(g$source_id, g$target_id))
    ne <- match(paste(m$source_id, m$target_id), paste(g$source_id, g$target_id))
    stopifnot(!anyNA(ne), !anyNA(oe), sum(changed) == 43, !anyDuplicated(m$target_id))
    delta <- m$weight * (d$y[new] - d$y[old])
    result <- data.frame(year,
      linkage = kind, source_id = m$source_id[changed],
      source_name = a$gp_new_2010[ai][changed], block = a$mnrega_block_name[ai][changed],
      old_target = d$state_key[old][changed], new_target = d$state_key[new][changed],
      old_name = d$name[old][changed], new_name = d$name[new][changed],
      old_distance = g$distance[oe][changed], new_distance = g$distance[ne][changed],
      new_rank = g$rank[ne][changed], old_y = d$y[old][changed], new_y = d$y[new][changed],
      weight = m$weight[changed], contribution = delta[changed],
      new_previously_unused = !m$target_id[changed] %in% a$state_key,
      old_missing_years = d$missing_years[old][changed],
      new_missing_years = d$missing_years[new][changed]
    )
    result$old_gp_distance <- stringdist::stringdist(
      normalize(result$source_name), normalize(result$old_name),
      method = "jw", p = 0
    )
    result$new_gp_distance <- stringdist::stringdist(
      normalize(result$source_name), normalize(result$new_name),
      method = "jw", p = 0
    )
    result$distance_loss <- result$new_distance - result$old_distance
    result <- result[order(-abs(result$contribution)), ]
    rows[[length(rows) + 1]] <- result
    summaries[[length(summaries) + 1]] <- data.frame(year,
      linkage = kind,
      baseline = sum(m$weight * d$y[old]), alternative = sum(m$weight * d$y[new]),
      shift = sum(delta),
      changed = 43, previously_unused = sum(result$new_previously_unused),
      exact_accepted_overwritten = sum(result$old_distance < 1e-12),
      median_old_full_distance = median(result$old_distance),
      median_new_full_distance = median(result$new_distance),
      median_old_gp_distance = median(result$old_gp_distance),
      median_new_gp_distance = median(result$new_gp_distance),
      new_gp_over_02 = sum(result$new_gp_distance > .2), new_rank_over_1 = sum(result$new_rank > 1),
      mean_absolute_outcome_change = mean(abs(result$new_y - result$old_y)),
      max_new_y = max(result$new_y),
      top1_share = max(abs(result$contribution)) / sum(abs(result$contribution)),
      top5_share = sum(head(abs(result$contribution), 5)) / sum(abs(result$contribution)),
      top10_share = sum(head(abs(result$contribution), 10)) / sum(abs(result$contribution)),
      missing_any_changed = sum(result$old_missing_years > 0 | result$new_missing_years > 0),
      new_all_missing = sum(result$new_missing_years == 4),
      shift_from_new_all_missing = sum(result$contribution[result$new_missing_years == 4])
    )
  }
}
changed <- do.call(rbind, rows)
summary <- do.call(rbind, summaries)
write.csv(changed, file.path(out, "changed_links.csv"), row.names = FALSE)
write.csv(summary, file.path(out, "summary.csv"), row.names = FALSE)
print(summary, row.names = FALSE)

# Each restriction applies to alternatives; the accepted map remains available.
g$i <- match(g$source_id, a$key_2010)
g$j <- match(g$target_id, d$state_key)
g$accepted <- g$target_id == a$state_key[g$i]
old_edge <- match(paste(a$key_2010, a$state_key), paste(g$source_id, g$target_id))
g$gp_distance <- stringdist::stringdist(
  normalize(a$gp_new_2010[g$i]), d$name_normalized[g$j],
  method = "jw", p = 0
)
g$distance_loss <- g$distance - g$distance[old_edge][g$i]
locked <- g$distance[old_edge] < 1e-12
variants <- list(
  broad = rep(TRUE, nrow(g)),
  local_name_01 = g$gp_distance < .1,
  near_best_001 = g$distance_loss <= .01 + 1e-12,
  protect_exact = !locked[g$i],
  no_new_donors = g$target_id %in% a$state_key,
  no_new_missing = d$missing_years[g$j] == 0,
  local_and_protect = g$gp_distance < .1 & !locked[g$i]
)
fits <- list()
map_rows <- list()
for (year in c(2005, 2010)) {
  weights <- w$weight[w$year == year & w$linkage == "accepted"]
  ids <- w$source_id[w$year == year & w$linkage == "accepted"]
  weights <- weights[match(a$key_2010, ids)]
  for (variant in names(variants)) {
    e <- g[g$accepted | variants[[variant]], ]
    donor_ids <- unique(e$j)
    n <- nrow(a)
    b <- length(donor_ids)
    v <- nrow(e)
    dense <- rbind(
      cbind(e$i, seq_len(v), 1),
      cbind(n + match(e$j, donor_ids), seq_len(v), 1),
      cbind(n + b + 1L, seq_len(v), as.integer(!e$accepted))
    )
    for (direction in c("min", "max")) {
      fit <- lpSolve::lp(direction, weights[e$i] * d$y[e$j],
        const.dir = c(rep("=", n), rep("<=", b), "<="), const.rhs = c(rep(1, n + b), 43),
        dense.const = dense, timeout = 45
      )
      stopifnot(fit$status == 0)
      fractional <- max(abs(fit$solution - round(fit$solution))) > 1e-7
      used_integer_solver <- FALSE
      if (fractional) {
        candidate <- lpSolve::lp(direction, weights[e$i] * d$y[e$j],
          const.dir = c(rep("=", n), rep("<=", b), "<="), const.rhs = c(rep(1, n + b), 43),
          dense.const = dense, all.bin = TRUE, timeout = 3
        )
        if (candidate$status == 0) {
          fit <- candidate
          fractional <- FALSE
          used_integer_solver <- TRUE
        }
      }
      map <- NULL
      if (!fractional) {
        chosen <- which(fit$solution > .5)
        map <- integer(n)
        map[e$i[chosen]] <- e$j[chosen]
        stopifnot(
          length(chosen) == n, all(map > 0), !anyDuplicated(map),
          sum(d$state_key[map] != a$state_key) <= 43,
          abs(sum(weights * d$y[map]) - fit$objval) < 1e-7
        )
      }
      fits[[length(fits) + 1]] <- data.frame(year, variant, direction,
        value = fit$objval,
        changed = if (is.null(map)) NA_integer_ else sum(d$state_key[map] != a$state_key),
        edges = nrow(e),
        integer_solve = used_integer_solver, attained = !fractional
      )
      if (!is.null(map)) {
        map_rows[[length(map_rows) + 1]] <- data.frame(year, variant, direction,
          source_id = a$key_2010, target_id = d$state_key[map], weight = weights, outcome = d$y[map]
        )
      }
      cat(year, variant, direction, fit$objval, "\n")
    }
  }
}
write.csv(do.call(rbind, fits), file.path(out, "restricted_graph_bounds.csv"), row.names = FALSE)
arrow::write_parquet(do.call(rbind, map_rows), file.path(out, "restricted_graph_witnesses.parquet"))

source(file.path(root, "R/core.R"))
source(file.path(root, "R/lottery.R"))
lottery_fields <- unlist(lapply(c(2005, 2010), function(year) {
  paste0(c("female_res_", "caste_res_", "dist_name_new_", "samiti_name_new_"), year)
}))
lottery <- as.data.frame(arrow::read_parquet(
  file.path(quota, "data/raj/mnrega_elex_raj_05_10.parquet"),
  col_select = dplyr::all_of(lottery_fields)
))
restricted_maps <- do.call(rbind, map_rows)
endpoint_p <- list()
for (year in c(2005, 2010)) {
  other <- if (year == 2005) 2010 else 2005
  fields <- c(
    paste0("dist_name_new_", year), paste0("samiti_name_new_", year),
    paste0("caste_res_", year), paste0("female_res_", other)
  )
  strata <- do.call(paste, c(lottery[fields], sep = "|"))
  selected <- restricted_maps[
    restricted_maps$year == year &
      restricted_maps$variant %in% c("local_name_01", "near_best_001", "local_and_protect"),
  ]
  selected$case <- paste(selected$variant, selected$direction, sep = ":")
  cases <- split(selected, selected$case)
  outcomes <- vapply(cases, function(part) {
    part$outcome[match(a$key_2010, part$source_id)]
  }, numeric(nrow(a)))
  z <- lottery[[paste0("female_res_", year)]]
  weights <- conditional_lottery(z, strata)$weights
  set.seed(69152026 + year)
  reference <- lottery_reference(outcomes, z, strata, 19999)
  result <- lottery_tail_summary(reference, drop(crossprod(weights, outcomes)), family_size = 12)
  result$year <- year
  result$case <- names(cases)
  endpoint_p[[as.character(year)]] <- result
}
write.csv(do.call(rbind, endpoint_p),
  file.path(out, "restricted_endpoint_p.csv"),
  row.names = FALSE
)

bounds <- do.call(rbind, fits)
lines <- c(
  "# Audit of the 43-link sensitivity result", "",
  "The coefficients and lottery p-values reproduce independently. The striking shifts",
  "rely on a permissive candidate graph: name distance was measured on concatenated",
  "district, block, and GP names. Shared geography lets weak GP-name alternatives pass.", "",
  "Every earlier 43-change witness uses candidates worse than the accepted match.",
  "The changed outcomes differ by roughly 195–239 projects on average. Between 14 and",
  "26 accepted exact-name links are replaced, and 6–9 newly selected donors have all",
  "four annual outcomes missing and therefore become zero under the existing policy.", "",
  "The arithmetic is valid conditional on this graph. It does not establish that",
  "credible near-tie identity uncertainty causes the same instability.", "",
  "## Restrictions on alternatives, keeping accepted links available", "",
  "All rows keep the cohort, regression, lottery assumptions, donor uniqueness, and",
  "at-most-43-change budget fixed. Seven diagnostic specifications are shown, not",
  "selected on their outcome. These were investigated after seeing the broad-graph",
  "result; they are not independently calibrated truth-containment sets.", "",
  "| Year | Additional restriction | Lower coefficient bound | Upper coefficient bound | Edges |",
  "|---:|:---|---:|---:|---:|"
)
labels <- c(
  broad = "Broad cutoff only", local_name_01 = "GP-name distance < 0.1",
  near_best_001 = "Full-name distance within 0.01 of accepted",
  protect_exact = "Preserve accepted exact-name links",
  no_new_donors = "Use only already-selected donors",
  no_new_missing = "New donors have all four observed years",
  local_and_protect = "GP-name distance < 0.1 and preserve exact links"
)
for (year in c(2005, 2010)) {
  for (variant in names(variants)) {
    part <- bounds[bounds$year == year & bounds$variant == variant, ]
    lines <- c(lines, sprintf(
      "| %d | %s | %.4f | %.4f | %d |", year, labels[[variant]],
      part$value[part$direction == "min"], part$value[part$direction == "max"], part$edges[1]
    ))
  }
}
lines <- c(
  lines, "",
  "Bounds optimize the entire declared graph subject to the change budget. An integral",
  "linear-program optimum or a certified integer-program optimum supplies an attaining",
  "witness. When the integer refinement does not finish, the LP relaxation supplies",
  "an outer bound; `attained` in the CSV distinguishes these. The GP-name and near-best",
  "ranges have attaining witnesses. Earlier broad-graph examples searched only a subset",
  "of feasible maps, so the newly optimized broad ranges can be wider.", "",
  "GP-only distance and near-best margins are illustrative restrictions. Retaining",
  "all accepted links guarantees baseline feasibility, not their correctness. Tighter",
  "graphs may omit true alternatives; independent identity information is needed to",
  "choose defensible restrictions. Exact-name equality is not ground truth either.", "",
  "## Concrete changes in the earlier 2005 negative witness", "",
  "| Source GP | Accepted donor | Alternative donor | Accepted projects | Alternative projects |",
  "|:---|:---|:---|---:|---:|"
)
examples <- changed[changed$year == 2005 & changed$linkage == "budget_43_minimum", ]
examples <- head(examples, 5)
lines <- c(
  lines, sprintf(
    "| %s | %s | %s | %g | %g |", examples$source_name, examples$old_name,
    examples$new_name, examples$old_y, examples$new_y
  ), "",
  "Full changed identities, distances, candidate ranks, outcome differences, and their",
  "coefficient contributions are saved in [changed_links.csv](changed_links.csv).",
  "[Summary](summary.csv) reports outcome concentration and missingness contributions.", "",
  "[Restricted bounds](restricted_graph_bounds.csv) and",
  "[attaining assignments](restricted_graph_witnesses.parquet) preserve the tighter-set",
  "calculations. [Endpoint p-values](restricted_endpoint_p.csv) evaluate the attaining",
  "coefficient endpoints with 19,999 draws each and simultaneous 95% Monte Carlo",
  "intervals; they are not claimed global p-value extrema.", "",
  "[Independent Python refits](independent-review.md) and within-stratum permutations",
  "reproduced the original six accepted/min43/max43 coefficient and p-value results.",
  "Original quota",
  "data remain unchanged. These findings qualify the realistic interpretation of the",
  "earlier result rather than changing its arithmetic."
)
writeLines(lines, file.path(out, "report.md"))

paths <- c(
  file.path(quota, "data/raj/mnrega_elex_raj_05_10.parquet"),
  file.path(quota, "data/mnrega/mnrega_r6.parquet"),
  file.path(quota, "data/mnrega/raj_mnrega_transliteration.csv"),
  file.path(root, "application/results/candidate_graph.parquet"),
  file.path(root, "application/results/lottery/witnesses.parquet")
)
manifest <- data.frame(
  path = paths,
  sha256 = vapply(paths, digest::digest, character(1), algo = "sha256", file = TRUE)
)
write.csv(manifest, file.path(out, "source_manifest.csv"), row.names = FALSE)
writeLines(
  trimws(capture.output(sessionInfo()), which = "right"), file.path(out, "sessionInfo.txt")
)
