EVENT_TYPES =
  # business event types
  hold: 'hold'
  release: 'release'
  booking: 'booking'
  # infrastructural event types
  conceptRequest: 'concept_request'
  httpRequest: 'http_request'
  startup: 'startup'
  exception: 'exception'

class Logger
  constructor: (@dependencies, @scoped_properties) ->
    EventLogger = makeEventLogger(@dependencies, @scoped_properties)
    for name, event_type of EVENT_TYPES
      @[name] = new EventLogger(event_type)

  with: (scoped_properties) ->
    new Logger(@dependencies, Object.assign({}, @scoped_properties, scoped_properties))

makeEventLogger = ({now, output}, scoped_properties) -> class
  constructor: (@type) ->
    @debug = output_log('DEBUG')
    @info = output_log('INFO')
    @warning = output_log('WARNING')
    @error = output_log('ERROR')
    @critical = output_log('CRITICAL')

  output_log = (severity) -> (extra_properties) ->
    default_properties =
      service: 'default_service_name' # TODO: should probably remove this?
      timestamp: now()
      event_type: @type
      severity: severity

    unless typeof extra_properties == 'object'
      extra_properties =
        message: extra_properties

    all_properties = Object.assign({}, default_properties, scoped_properties, extra_properties)
    output.log JSON.stringify(all_properties)

module.exports = Logger
