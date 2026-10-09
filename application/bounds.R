args <- commandArgs(trailingOnly = TRUE)
source_root <- if (length(args)) {
  normalizePath(args[1], mustWork = TRUE)
} else {
  normalizePath(file.path("..", "quota_spending"), mustWork = TRUE)
}
script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
out <- file.path(dirname(normalizePath(script)), "results")
for (p in c("arrow", "lpSolve", "digest")) {
  if (!requireNamespace(p, quietly = TRUE)) stop("Install required package: ", p)
}
graph <- as.data.frame(arrow::read_parquet(file.path(out, "candidate_graph.parquet")))
source_path <- file.path(source_root, "data/raj/mnrega_elex_raj_05_10.parquet")
target_path <- file.path(source_root, "data/mnrega/mnrega_r6.parquet")
source <- as.data.frame(arrow::read_parquet(source_path, col_select = c(
  "key_2010", "state_key", "female_res_2005", "female_res_2010"
)))
target <- as.data.frame(arrow::read_parquet(target_path, col_select = c(
  "state_key", paste0("total_comp_project_", 2011:2014)
)))
target$y <- rowSums(target[paste0("total_comp_project_", 2011:2014)], na.rm = TRUE)
x <- model.matrix(~ female_res_2005 + female_res_2010, data = source)
weights <- solve(crossprod(x), t(x))
graph <- graph[
  graph$source_eligible & graph$target_eligible & graph$distance < .1 &
    graph$source_id %in% source$key_2010,
]
graph$y <- target$y[match(graph$target_id, target$state_key)]
stopifnot(!anyNA(graph$y))
point <- drop(weights %*% target$y[match(source$state_key, target$state_key)])
blocks <- split(graph, graph$block_key)
results <- witnesses <- list()
for (coefficient in 2:3) {
  bounds <- independent_bounds <- c(min = 0, max = 0)
  for (edges in blocks) {
    source_ids <- unique(edges$source_id)
    target_ids <- unique(edges$target_id)
    a <- matrix(0, nrow = length(source_ids) + length(target_ids), ncol = nrow(edges))
    a[cbind(match(edges$source_id, source_ids), seq_len(nrow(edges)))] <- 1
    a[cbind(length(source_ids) + match(edges$target_id, target_ids), seq_len(nrow(edges)))] <- 1
    costs <- weights[coefficient, match(edges$source_id, source$key_2010)] * edges$y
    independent_bounds <- independent_bounds + c(
      min = sum(vapply(split(costs, edges$source_id), min, numeric(1))),
      max = sum(vapply(split(costs, edges$source_id), max, numeric(1)))
    )
    for (direction in names(bounds)) {
      fit <- lpSolve::lp(
        direction, costs, a,
        c(rep("=", length(source_ids)), rep("<=", length(target_ids))),
        rep(1, nrow(a))
      )
      stopifnot(fit$status == 0)
      # The bipartite assignment polytope is integral; verify the returned vertex.
      stopifnot(max(abs(fit$solution - round(fit$solution))) < 1e-6)
      source_totals <- a[seq_along(source_ids), , drop = FALSE] %*% fit$solution
      stopifnot(max(abs(source_totals - 1)) < 1e-6)
      chosen <- fit$solution > .5
      witnesses[[length(witnesses) + 1L]] <- data.frame(
        term = rownames(weights)[coefficient], direction,
        source_id = edges$source_id[chosen], target_id = edges$target_id[chosen],
        contribution = costs[chosen]
      )
      bounds[direction] <- bounds[direction] + fit$objval
    }
  }
  stopifnot(
    point[coefficient] >= bounds["min"] - 1e-6,
    point[coefficient] <= bounds["max"] + 1e-6
  )
  results[[coefficient - 1L]] <- data.frame(
    term = rownames(weights)[coefficient], current = point[coefficient],
    lower = bounds["min"], upper = bounds["max"],
    independent_lower = independent_bounds["min"],
    independent_upper = independent_bounds["max"],
    n_sources = nrow(source), n_edges = nrow(graph), n_blocks = length(blocks)
  )
}
results <- do.call(rbind, results)
witnesses <- do.call(rbind, witnesses)
for (term in results$term) {
  for (direction in c("min", "max")) {
    w <- witnesses[witnesses$term == term & witnesses$direction == direction, ]
    endpoint <- results[results$term == term, if (direction == "min") "lower" else "upper"]
    stopifnot(
      nrow(w) == nrow(source), !anyDuplicated(w$source_id),
      !anyDuplicated(w$target_id), abs(sum(w$contribution) - endpoint) < 1e-6
    )
  }
}
arrow::write_parquet(witnesses, file.path(out, "coefficient_bound_witnesses.parquet"))
write.csv(results, file.path(out, "coefficient_reconstruction_bounds.csv"), row.names = FALSE)
paths <- c(source_path, target_path, file.path(out, "candidate_graph.parquet"))
write.csv(data.frame(
  path = paths,
  sha256 = vapply(paths, digest::digest, character(1), algo = "sha256", file = TRUE)
), file.path(out, "bounds_source_manifest.csv"), row.names = FALSE)
print(results)
