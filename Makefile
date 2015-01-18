MOCHA_OPTS = --require coffee-script/register --compilers coffee:coffee-script --check-leaks
REPORTER = spec

check: test

test: MULTI="${REPORTER}=- html-cov=coverage/coverage.html"
test: cover test-unit

ci: MULTI="spec=- mocha-lcov-reporter=coverage/lcov.info"
ci: cover test-unit

test-unit:
	mkdir -p coverage && \
	NODE_ENV=test multi=$(MULTI) \
		./node_modules/mocha/bin/_mocha \
			--reporter mocha-multi \
			$(MOCHA_OPTS)

build: clean
	./node_modules/.bin/coffee -o ./lib -c ./src

cover: clean
	./node_modules/.bin/coffeeCoverage ./src ./lib

report-cov:
	cat ./coverage/lcov.info | ./node_modules/.bin/coveralls ./src

clean:
	rm -rf ./lib ./coverage; exit 0


.PHONY: test
