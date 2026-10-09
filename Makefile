R = Rscript --vanilla
QUOTA_PATH ?= ../quota_spending

.PHONY: test lint check pilot simulate application observational report graph-information lottery linkage-audit identifier-validation methods background all

test:
	$(R) scripts/test.R

lint:
	$(R) scripts/lint.R

check: test lint

pilot:
	$(R) scripts/simulate.R 200 pilot

simulate:
	$(R) scripts/simulate.R 2000 final

graph-information:
	$(R) scripts/graph-information.R

observational:
	$(R) scripts/observational.R 2000

application:
	$(R) application/run.R $(QUOTA_PATH)
	$(R) application/bounds.R $(QUOTA_PATH)

lottery:
	$(R) application/lottery.R $(QUOTA_PATH)

linkage-audit:
	$(R) application/linkage-audit.R $(QUOTA_PATH)

identifier-validation:
	$(R) scripts/identifier-validation.R final

methods: check graph-information identifier-validation
	$(MAKE) report

report:
	$(R) scripts/render-methods.R
	cd manuscript && pdflatex -interaction=nonstopmode -halt-on-error paper.tex > /dev/null
	cd manuscript && pdflatex -interaction=nonstopmode -halt-on-error paper.tex > /dev/null

background:
	$(R) scripts/render-results.R final
	cd manuscript && pdflatex -interaction=nonstopmode -halt-on-error background.tex > /dev/null
	cd manuscript && pdflatex -interaction=nonstopmode -halt-on-error background.tex > /dev/null

all: methods simulate observational application lottery linkage-audit background
