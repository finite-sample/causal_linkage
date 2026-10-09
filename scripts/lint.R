source("R/core.R")
source("R/graph.R")
source("R/information.R")
source("R/accuracy.R")
files <- c(
  list.files("R", "[.]R$", full.names = TRUE),
  list.files("scripts", "[.]R$", full.names = TRUE),
  list.files("tests", "[.]R$", recursive = TRUE, full.names = TRUE)
)
lints <- unlist(lapply(files, lintr::lint), recursive = FALSE)
if (length(lints)) {
  print(lints)
  stop("Lint failures: ", length(lints))
}
cat("Lint clean: ", length(files), " R files\n", sep = "")
