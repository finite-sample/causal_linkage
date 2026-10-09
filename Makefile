R = Rscript --vanilla

.PHONY: test lint check graph-information identifier-validation report methods

test:
	$(R) scripts/test.R

lint:
	$(R) scripts/lint.R

check: test lint

graph-information:
	$(R) scripts/graph-information.R

identifier-validation:
	$(R) scripts/identifier-validation.R final

report:
	$(R) scripts/render-methods.R
	cd manuscript && pdflatex -interaction=nonstopmode -halt-on-error paper.tex > /dev/null
	cd manuscript && pdflatex -interaction=nonstopmode -halt-on-error paper.tex > /dev/null

methods: check graph-information identifier-validation
	$(MAKE) report
