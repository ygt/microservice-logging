require 'json'
require 'time'

require_relative './json_event_logger'

# Log all the things in JSON
class MicroserviceLogger
  def initialize(clock, output, scoped_properties = {})
    @clock = clock
    @output = output
    @scoped_properties = scoped_properties
    @event_loggers = {}
  end

  def with(scoped_properties)
    MicroserviceLogger.new(@clock, @output, scoped_properties)
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

  EVENT_TYPES = [
    :http_request,
    :applejack,
    :startup,
    :exception
  ].freeze

  private_constant :EVENT_TYPES

  EVENT_TYPES.each do |method_name|
    event_type = method_name.to_s
    define_method(method_name) do
      @event_loggers[method_name] ||=
        JsonEventLogger.new(@clock, @output, @scoped_properties, event_type)
    end
  end
end
