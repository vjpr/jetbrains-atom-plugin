NODE_PATH := NODE_PATH='lib:app'

run:

	$(NODE_PATH) nodemon --watch app --watch lib app.coffee

compile:

	node app.js

cake:

	$(NODE_PATH) icake $(arg)

prod:

	NODE_ENV=production node app.js

debug-inspector:

	node-inspector &

debug1:

	node --debug app

debug-brk:

	node --debug-brk app

test:

	@NODE_ENV=test $(NODE_PATH) ./node_modules/.bin/mocha $(arg)

testw:

	@NODE_ENV=test $(NODE_PATH) nodemon --watch app --watch test \
	  ./node_modules/.bin/mocha \
	  $(arg)

testww:

	@NODE_ENV=test $(NODE_PATH) ./node_modules/.bin/mocha \
		--growl \
		--watch

testc:

	open http://localhost:3030/test

.PHONY: test testw testc run debug prod debug-inspector debug1 debug-brk compile
