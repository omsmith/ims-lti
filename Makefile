MOCHA_OPTS = --compilers coffee:coffee-script -t 8000
REPORTER = spec

check: test

test: test-unit

test-unit:
	@NODE_ENV=test; ./node_modules/.bin/mocha \
    --reporter $(REPORTER) \
    $(MOCHA_OPTS)


.PHONY: test
