options(warn = 2)
testthat::test_dir("tests/testthat", reporter = "summary", stop_on_failure = TRUE)
