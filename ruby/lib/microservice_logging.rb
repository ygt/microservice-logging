require 'json'
require 'time'

require_relative './json_event_logger'

# Log all the things in JSON
class MicroserviceLogger
  def initialize(service_name:,
                 clock:,
                 output:,
                 scoped_properties: {},
                 events: DEFAULT_EVENT_TYPES)
    @service_name = service_name
    @clock = clock
    @output = output
    @scoped_properties = scoped_properties
    @event_loggers = {}
    @events = events
    @events.each do |method_name|
      event_type = method_name.to_s
      @event_loggers[method_name] =
        JsonEventLogger.new(:service_name => @service_name,
                            :clock => @clock,
                            :output => @output,
                            :scoped_properties => @scoped_properties,
                            :event_type => event_type)
    end
  end

  def method_missing(event)
    super unless @events.include? event
    @event_loggers[event]
  end

  DEFAULT_EVENT_TYPES = [
    :http_request,
    :applejack,
    :startup,
    :exception
  ].freeze

  def with(scoped_properties)
    MicroserviceLogger.new(:service_name => @service_name,
                           :clock => @clock,
                           :output => @output,
                           :scoped_properties => scoped_properties)
  end

  # The fields 'event_type' and 'serverity' in the JSON output that is logged
  # are not passed as parameters, but as methods.
  #
  # Therefore to log something like
  #
  #   logger.log(
  #     'event_type' => 'startup',
  #     'serverity' => 'info',
  #     'other_property' => 'some value',
  #     ...
  #   )
  #
  # one instead will call
  #
  #   logger.startup.info('other_property' => 'some value')
  #
  # The event types are defined on this class.
  #
  # Each of them returns a private JsonEventLogger that in turn has the methods
  # corresponding to the severity levels.
end
