class Logger {
  constructor (configuration, scopedProperties) {
    const {now, output, events} = configuration
    this.configuration = configuration
    this.now = now
    if (output.log) {
      this.output = output.log.bind(output)
    } else {
      this.output = output
    }
    this.events = events
    this.scopedProperties = scopedProperties

    const EventLogger = makeEventLogger({now: this.now, output: this.output}, this.scopedProperties)
    for (let name in events) {
      const eventType = events[name]
      this[name] = new EventLogger(eventType)
    }
  }

  with (scopedProperties) {
    return new Logger(this.configuration, Object.assign({}, this.scopedProperties, scopedProperties))
  }
}

const makeEventLogger = ({now, output}, scopedProperties) => {
  const outputLog = severity => function (extraProperties) {
    const defaultProperties = {
      timestamp: now(),
      event_type: this.type,
      severity
    }

    if (typeof extraProperties !== 'object') {
      extraProperties =
        {message: extraProperties}
    }

    const allProperties = Object.assign({}, defaultProperties, scopedProperties, extraProperties)
    output(JSON.stringify(allProperties))
  }

  return class {
    constructor (type) {
      this.type = type
      this.debug = outputLog('DEBUG')
      this.info = outputLog('INFO')
      this.warning = outputLog('WARNING')
      this.error = outputLog('ERROR')
      this.critical = outputLog('CRITICAL')
    }
  }
}

module.exports = Logger
