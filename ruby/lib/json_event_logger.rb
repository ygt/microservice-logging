# A machine-readable first, human-readable second logging library
class MicroserviceLogger
  class JsonEventLogger
    def initialize(service_name:,
                   clock:,
                   output:,
                   scoped_properties:,
                   event_type:)
      @service_name = service_name
      @clock = clock
      @output = output
      @scoped_properties = scoped_properties
      @event_type = event_type
    end

    def debug(extra_properties)
      log 'DEBUG', normalize(extra_properties)
    end

    def info(extra_properties)
      log 'INFO', normalize(extra_properties)
    end

    def warning(extra_properties)
      log 'WARNING', normalize(extra_properties)
    end

    def error(extra_properties)
      log 'ERROR', normalize(extra_properties)
    end

    def critical(extra_properties)
      log 'CRITICAL', normalize(extra_properties)
    end

    private

    def log(severity, extra_properties)
      properties =
        required_properties(severity)
        .merge(@scoped_properties)
        .merge(extra_properties)

      @output.puts(properties.to_json)
    end

    def required_properties(severity)
      {
        service: @service_name,
        event_type: @event_type,
        timestamp: @clock.now.utc.iso8601(3),
        severity: severity
      }
    end

    def normalize(properties)
      case properties
      when Hash
        properties
      else
        { message: properties.to_s }
      end
    end
  end

  private_constant :JsonEventLogger
end
