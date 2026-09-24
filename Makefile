HELM ?= helm
CHARTS := $(wildcard charts/*)

.PHONY: test lint template

test: lint template

lint:
	$(HELM) lint $(CHARTS)

template:
	@set -e; for chart in $(CHARTS); do \
		echo "==> $$chart (default values)"; \
		$(HELM) template test $$chart > /dev/null; \
		for values in $$chart/examples/*.yaml; do \
			[ -e "$$values" ] || continue; \
			echo "==> $$chart -f $$values"; \
			$(HELM) template test $$chart -f $$values > /dev/null; \
		done; \
	done
