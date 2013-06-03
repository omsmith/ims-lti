MOCHA_OPTS = --compilers coffee:coffee-script --check-leaks
REPORTER = spec

check: test

test: test-unit

test-unit:
	@NODE_ENV=test; ./node_modules/mocha/bin/mocha \
    --reporter $(REPORTER) \
    $(MOCHA_OPTS)


.PHONY: test
