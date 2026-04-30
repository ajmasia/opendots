SHELL_FILES := bin/opendots lib/*.sh install.sh tests/test_helper.bash completions/opendots.bash

.PHONY: lint fmt fmt-check test check

lint:
	shellcheck $(SHELL_FILES)

fmt:
	shfmt -w -i 2 -ci -bn $(SHELL_FILES)

fmt-check:
	shfmt -d -i 2 -ci -bn $(SHELL_FILES)

test:
	bats --recursive tests/

check: lint fmt-check test
