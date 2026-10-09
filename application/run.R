args <- commandArgs(trailingOnly = TRUE)
source_root <- if (length(args)) {
  normalizePath(args[1], mustWork = TRUE)
} else {
  normalizePath(file.path("..", "quota_spending"), mustWork = TRUE)
}
script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
out <- file.path(dirname(normalizePath(script)), "results")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
packages <- c("arrow", "dplyr", "stringdist", "stringi", "sandwich", "digest")
missing_packages <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages)) {
  stop(
    "Install required packages: ",
    paste(missing_packages,
      collapse = ", "
    )
  )
}
suppressPackageStartupMessages(library(dplyr))
provenance <- new.env(parent = emptyenv())
provenance$inputs <- character()
input <- function(relative) {
  provenance$inputs <- union(provenance$inputs, relative)
  file.path(source_root, relative)
}
save_csv <- function(x, name) write.csv(x, file.path(out, name), row.names = FALSE, na = "")
normalize_string <- function(x) {
  x <- stringi::stri_trans_tolower(stringi::stri_trans_general(x, "Latin-ASCII"))
  gsub("[[:punct:]]", "", trimws(gsub("\\s+", " ", x)))
}
read_panel <- function(method) {
  suffix <- if (method == "exact") "_strict" else ""
  as.data.frame(arrow::read_parquet(input(paste0(
    "data/raj/mnrega_elex_raj_05_10",
    suffix,
    ".parquet"
  ))))
}
panels <- list(fuzzy = read_panel("fuzzy"), exact = read_panel("exact"))
for (p in panels) stopifnot(!anyDuplicated(p$key_2010), !anyDuplicated(p$state_key))
common <- intersect(panels$fuzzy$key_2010, panels$exact$key_2010)
bases <- c("total", "connectivity", "sanitation", "water_conserve", "water_trad", "drinking_water")
components <- c("comp_project", "comp_expenditure", "ongoing_project", "ongoing_expenditure")
outcomes <- as.vector(outer(bases, components, paste, sep = "_"))
missingness <- estimates <- missing_by_assignment <- list()
for (method in names(panels)) {
  p <- panels[[method]]
  for (outcome in outcomes) {
    columns <- paste0(outcome, "_", 2011:2014)
    stopifnot(all(columns %in% names(p)))
    annual <- as.matrix(p[columns])
    observed <- rowSums(!is.na(annual))
    p$y <- rowSums(annual, na.rm = TRUE)
    missing_by_assignment[[length(missing_by_assignment) + 1L]] <-
      data.frame(p[c("female_res_2005", "female_res_2010")], observed = observed) |>
      group_by(female_res_2005, female_res_2010) |>
      summarise(
        n = n(),
        all_missing = sum(observed == 0),
        partial_missing = sum(observed > 0 & observed < 4),
        .groups = "drop"
      ) |>
      mutate(method = method, outcome = outcome)
    for (cohort in c("method", "common")) {
      keep <- if (cohort == "common") p$key_2010 %in% common else rep(TRUE, nrow(p))
      for (policy in c("current_na_rm", "complete_four_years")) {
        d <- p[keep & (policy == "current_na_rm" | observed == 4L), ]
        if (nrow(d) <= 3L) next
        fit <- lm(y ~ female_res_2005 + female_res_2010, data = d)
        cf <- coef(summary(fit))
        robust <- sqrt(diag(sandwich::vcovHC(fit, type = "HC2")))
        estimates[[length(estimates) + 1L]] <- data.frame(
          method, cohort,
          missing_policy = policy, outcome,
          term = rownames(cf), estimate = cf[, 1], se_ols = cf[, 2],
          se_hc2 = robust,
          n = nobs(fit),
          control_00_mean = mean(d$y[d$female_res_2005 == 0 & d$female_res_2010 == 0],
            na.rm = TRUE
          )
        )
      }
    }
    missingness[[length(missingness) + 1L]] <- data.frame(
      method, outcome,
      n = nrow(p), all_four_missing = sum(observed == 0),
      partial_missing = sum(observed > 0 & observed < 4), complete = sum(observed == 4),
      zero_totals = sum(p$y == 0), mean_total = mean(p$y)
    )
  }
}
estimates <- bind_rows(estimates)
common_fuzzy <- subset(estimates, method == "fuzzy" & cohort == "common")
common_exact <- subset(estimates, method == "exact" & cohort == "common")
stopifnot(
  identical(common_fuzzy$estimate, common_exact$estimate),
  identical(common_fuzzy$se_ols, common_exact$se_ols),
  identical(common_fuzzy$n, common_exact$n)
)
save_csv(estimates, "estimates.csv")
save_csv(bind_rows(missingness), "outcome_missingness.csv")
save_csv(bind_rows(missing_by_assignment), "missingness_by_assignment.csv")
cohorts <- bind_rows(lapply(names(panels), function(method) {
  panels[[method]] |>
    count(female_res_2005, female_res_2010, name = "n") |>
    mutate(method = method)
}))
save_csv(cohorts, "cohort_assignment_counts.csv")
pair_comparison <- merge(
  panels$fuzzy[c(
    "key_2010",
    "state_key"
  )],
  panels$exact[c(
    "key_2010",
    "state_key"
  )],
  by = "key_2010"
)
save_csv(data.frame(
  fuzzy_n = nrow(panels$fuzzy), exact_n = nrow(panels$exact), common_n = length(common),
  common_different_target = sum(pair_comparison$state_key.x != pair_comparison$state_key.y)
), "cohort_comparison.csv")

# Regenerate every within-district/block pair before nearest-neighbor or distance filtering.
elections <- as.data.frame(arrow::read_parquet(input("data/raj/elex_raj_05_10.parquet")))
crosswalk <- read.csv(input("data/raj/elex_mnrega_ps_block_crosswalk.csv"),
  na.strings = c(
    "",
    "NA"
  )
)
stopifnot(!anyDuplicated(crosswalk$elex_samiti_name))
elections$samiti_name_new_2010 <- tolower(elections$samiti_name_new_2010)
elections <- left_join(elections, crosswalk, by = c("samiti_name_new_2010" = "elex_samiti_name"))
elections$match_name <- normalize_string(gsub(
  " ",
  "",
  paste0(
    elections$dist_name_new_2010,
    elections$mnrega_block_name,
    elections$gp_new_2010
  )
))
elections$eligible_crosswalk <- !is.na(elections$mnrega_block_name)
duplicates <- elections$match_name[duplicated(elections$match_name)]
elections$original_eligible <- elections$eligible_crosswalk & !elections$match_name %in% duplicates
right <- as.data.frame(arrow::read_parquet(input("data/mnrega/mnrega_r6.parquet"),
  col_select = c(
    "state_key",
    "state",
    "district",
    "block",
    "panchayat"
  )
))
stopifnot(!anyDuplicated(right$state_key))
right <- right[right$state == "RAJASTHAN", ]
right$all_reports <- TRUE
for (report in c("r1", "r3", "r5")) {
  ids <- arrow::read_parquet(
    input(paste0(
      "data/mnrega/mnrega_",
      report,
      ".parquet"
    )),
    col_select = "state_key"
  )$state_key
  stopifnot(!anyDuplicated(ids))
  right$all_reports <- right$all_reports & right$state_key %in% ids
}
right$district <- tolower(right$district)
right$district[right$district == "sawai madhopur"] <- "sawaimadhopur"
right$district[right$district == "sri ganganagar"] <- "ganganagar"
trans <- read.csv(input("data/mnrega/raj_mnrega_transliteration.csv"), na.strings = c("", "NA"))
stopifnot(!anyDuplicated(trans$hindi))
right <- left_join(right, trans[c("hindi", "chat_gpt_fin")], by = c("panchayat" = "hindi"))
right$ascii_panchayat <- stringi::stri_trans_general(right$chat_gpt_fin, "Latin-ASCII")
use_original <- is.na(right$ascii_panchayat) & !is.na(right$panchayat)
right$ascii_panchayat[use_original] <- right$panchayat[use_original]
right$match_name <- gsub(
  " ",
  "",
  normalize_string(paste0(
    right$district,
    right$block,
    right$ascii_panchayat
  ))
)
intersected <- right[right$all_reports, ]
right_dupes <- intersected$match_name[duplicated(intersected$match_name)]
right$original_eligible <- right$all_reports & !right$match_name %in% right_dupes
right$block_key <- paste(tolower(right$district), tolower(right$block), sep = "|")
elections$block_key <- paste(tolower(elections$dist_name_new_2010),
  tolower(elections$mnrega_block_name),
  sep = "|"
)
graphs <- lapply(
  intersect(
    unique(elections$block_key[elections$eligible_crosswalk]),
    unique(right$block_key)
  ),
  function(key) {
    a <- elections[elections$eligible_crosswalk & elections$block_key == key, ]
    b <- right[right$block_key == key, ]
    distance <- stringdist::stringdistmatrix(a$match_name, b$match_name, method = "jw", p = 0)
    ix <- expand.grid(i = seq_len(nrow(a)), j = seq_len(nrow(b)))
    data.frame(
      source_id = a$key_2010[ix$i], target_id = b$state_key[ix$j], block_key = key,
      distance = as.vector(distance),
      source_eligible = a$original_eligible[ix$i],
      target_eligible = b$original_eligible[ix$j]
    )
  }
)
graph <- bind_rows(graphs)
arrow::write_parquet(graph, file.path(out, "candidate_graph.parquet"))
original <- graph |>
  filter(source_eligible, target_eligible) |>
  group_by(source_id) |>
  filter(distance == min(distance)) |>
  ungroup() |>
  filter(distance < .1) |>
  group_by(source_id) |>
  filter(n() == 1) |>
  ungroup() |>
  group_by(target_id) |>
  filter(n() == 1) |>
  ungroup()
saved_pairs <- panels$fuzzy |> transmute(source_id = key_2010, target_id = state_key)
reconstructed_only <- anti_join(original, saved_pairs, by = c("source_id", "target_id"))
saved_only <- anti_join(saved_pairs, original, by = c("source_id", "target_id"))
validation <- data.frame(
  reconstructed_pairs = nrow(original), saved_pairs = nrow(saved_pairs),
  reconstructed_only = nrow(reconstructed_only), saved_only = nrow(saved_only)
)
save_csv(validation, "graph_reproduction.csv")
degrees <- graph |>
  filter(source_eligible, target_eligible) |>
  group_by(source_id) |>
  summarise(block_candidates = n(), candidates_below_01 = sum(distance < .1), .groups = "drop")
save_csv(data.frame(
  stage = c(
    "base_election_roster",
    "mapped_block",
    "source_after_original_dedupe",
    "r6_rajasthan",
    "four_report_intersection",
    "right_after_original_dedupe",
    "all_blocked_edges",
    "original_eligible_edges",
    "eligible_edges_below_01",
    "sources_with_multiple_below_01",
    "accepted_fuzzy",
    "accepted_exact"
  ),
  n = c(
    nrow(elections),
    sum(elections$eligible_crosswalk),
    sum(elections$original_eligible),
    nrow(right),
    sum(right$all_reports),
    sum(right$original_eligible),
    nrow(graph),
    sum(graph$source_eligible & graph$target_eligible),
    sum(graph$source_eligible & graph$target_eligible & graph$distance < .1),
    sum(degrees$candidates_below_01 > 1),
    nrow(original),
    nrow(panels$exact)
  )
), "selection_flow.csv")
selection <- elections |>
  mutate(
    in_fuzzy = key_2010 %in% panels$fuzzy$key_2010,
    in_exact = key_2010 %in% panels$exact$key_2010
  ) |>
  group_by(female_res_2005, female_res_2010) |>
  summarise(
    base_n = n(),
    fuzzy_n = sum(in_fuzzy),
    exact_n = sum(in_exact),
    fuzzy_rate = mean(in_fuzzy),
    exact_rate = mean(in_exact),
    .groups = "drop"
  )
save_csv(selection, "selection_by_assignment.csv")
for (state in c("raj", "up")) {
  links <- arrow::read_parquet(input(paste0("data/", state, "/lgd_election_links.parquet")))
  save_csv(
    links |> distinct(
      election_id,
      match_status
    ) |>
      count(match_status),
    paste0(
      state,
      "_lgd_status.csv"
    )
  )
}
for (f in c(
  "scripts/00_linkage.R",
  "scripts/03a_raj_elex_mnrega_join.R",
  "scripts/03b_up_elex_mnrega_join.R",
  "scripts/04_lgd_shrug_elex_join.R",
  "scripts/07a_raj_main_mnrega_outcomes.R",
  "scripts/00_utils.R",
  "ms/ms.tex",
  "tabs/mnrega_raj_05_10_main.tex"
)) {
  input(f)
}
save_csv(data.frame(
  path = provenance$inputs,
  bytes = file.info(file.path(source_root, provenance$inputs))$size,
  sha256 = vapply(
    file.path(
      source_root,
      provenance$inputs
    ),
    digest::digest,
    character(1),
    algo = "sha256",
    file = TRUE
  )
), "source_manifest.csv")
writeLines(
  c(
    paste(
      "Source root:",
      source_root
    ),
    trimws(capture.output(sessionInfo()), which = "right")
  ),
  file.path(
    out,
    "session_info.txt"
  )
)
stopifnot(validation$reconstructed_only == 0, validation$saved_only == 0)
print(validation)
print(estimates |> filter(
  outcome == "total_comp_project",
  missing_policy == "current_na_rm",
  term != "(Intercept)"
))

headline <- estimates |> filter(outcome == "total_comp_project", term != "(Intercept)")
summary_lines <- c(
  "# Generated Rajasthan MNREGA comparison",
  "", paste(
    "Outcome: total completed projects, summed over 2011–2014.",
    "Model: outcome ~ female_res_2005 + female_res_2010."
  ),
  "", "| Method | Cohort | Missing policy | Year | Estimate | OLS SE | HC2 SE | N |",
  "|---|---|---|---|---:|---:|---:|---:|"
)
for (i in seq_len(nrow(headline))) {
  r <- headline[i, ]
  summary_lines <- c(summary_lines, sprintf(
    "| %s | %s | %s | %s | %.6f | %.6f | %.6f | %d |",
    r$method,
    r$cohort,
    r$missing_policy,
    sub(
      "female_res_",
      "",
      r$term
    ),
    r$estimate,
    r$se_ols,
    r$se_hc2,
    r$n
  ))
}
summary_lines <- c(
  summary_lines, "", sprintf(
    paste(
      "The common cohort has %d election records;",
      "%d have different target records across methods."
    ),
    length(common),
    sum(pair_comparison$state_key.x != pair_comparison$state_key.y)
  ),
  "", paste(
    "HC2 is a conditional regression sensitivity calculation;",
    "it does not include linkage uncertainty or establish the randomization design."
  )
)
writeLines(summary_lines, file.path(out, "summary.md"))
