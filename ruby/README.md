# Ruby JSON logger

This library provides a minimal JSON logging interface suitable for use in microservices - see the parent project [here](https://github.com/ygt/microservice-logging)

## Install

	gem install microservice-logging

## Examples of use

All of the following code can be found [here](ruby/example-app.rb)

Instantiate a new logger like this:
<!--
	Logger = require './logger'

	log = new Logger
	  now: Date.now
	  output: console
	.with
	  service: 'my super service' -->

You can then use the logger by invoking it like so:
<!--
	log.startup.error
	  message: 'Emergency! There's an Emergency going on' -->

This will output:

	{"service":"my super service","timestamp":1468333486800,"event_type":"startup","severity":"ERROR","message":"Emergency! There's an Emergency going on"}

Although, obviously, the timestamp attribute will be different - this is the number of seconds since the epoch, in case you were wondering. If you want to add specific information (like request data) you can do so like this:

	<!-- log.httpRequest.info
      correlation_id: '126bb6fa-28a2-470f-b013-eefbf9182b2d'
      request:
        method: 'GET'
      response:
        status: 200 -->

Which prints:

	{"service":"my super service","timestamp":1468333607265,"event_type":"http_request","severity":"INFO","correlation_id":"126bb6fa-28a2-470f-b013-eefbf9182b2d","request":{"method":"GET"},"response":{"status":200}}

# Developing on the library

Pull Requests are most welcome - if you want to run the tests then simply:

  make check

All PRs that break the test suite will be politely declined :-)

# LICENSE

See [LICENSE](../LICENSE) file in parent project, but basically MIT.
