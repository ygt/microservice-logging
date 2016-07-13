.PHONY: build echo run repl
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

repl:
	docker run -it --rm \
	-v $(PWD):/home/elixir \
	ygt/microservice-logging-elixir \
	iex
