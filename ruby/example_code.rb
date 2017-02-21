require 'microservice_logging'
require 'time'

MY_EVENTS = [
  :http_request,
  :exception,
  :startup,
  :my_event,
  :my_other_event
].freeze

log = MicroserviceLogger.new(service_name: 'my_super_service',
                             clock: Time,
                             output: $stdout,
                             events: MY_EVENTS)

log.startup.error(message: "Emergency! There's an Emergency going on")

puts "\n"

log.http_request.info(correlation_id: '6889828a-6708-46f7-beec-870cf7b4ab6f',
                      request: { method: 'GET' },
                      response: { status_code: 200 })
