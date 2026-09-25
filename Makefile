HELM ?= helm
CHARTS := $(wildcard charts/*)

.PHONY: test lint template unittest

test: lint template unittest

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

unittest:
	$(HELM) unittest $(CHARTS)
