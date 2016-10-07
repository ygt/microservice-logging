.PHONY: build echo run lint test check repl
PWD = $(shell pwd)

build:
	docker build -t ygt/microservice-logging-elixir .

echo:
	@echo SCRIPT = $(SCRIPT)
	@echo pwd = $(PWD)

run:
	docker run -it --rm \
	-v $(PWD):/home/elixir \
	ygt/microservice-logging-elixir \
	elixir $(SCRIPT)

lint:
	@echo "No linting yet configured"

test:
	docker run -it --rm \
	-v $(PWD):/home/elixir \
	ygt/microservice-logging-elixir \
	mix run tests

check: lint test

repl:
	docker run -it --rm \
	-v $(PWD):/home/elixir \
	ygt/microservice-logging-elixir \
	iex
