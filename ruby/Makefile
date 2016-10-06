.PHONY: build test lint check run

build:
	docker build -t ygt/microservice-logging-ruby .

test:
	docker run \
	-it --rm \
	-v `pwd`:/var/app \
	ygt/microservice-logging-ruby \
	rspec --format documentation spec

lint:
	docker run -it --rm -v `pwd`:/var/app ygt/microservice-logging-ruby rubocop

check: lint test

run:
	docker run -it --rm -v `pwd`:/var/app ygt/microservice-logging-ruby bash
