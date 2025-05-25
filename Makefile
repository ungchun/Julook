TUIST := mise exec -- tuist

.PHONY: generate
generate:
	TUIST_ROOT_DIR=${PWD} $(TUIST) generate
