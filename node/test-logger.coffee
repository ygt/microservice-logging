expect = require('chai').expect
sinon = require 'sinon'
moment = require 'moment'
Logger = require './logger'

fromLogMessage = (output, {atIndex = 0} = {}) ->
  calledWith = output.args[atIndex]
  expect(calledWith, "The caller wrote to the output #{output.args.length} times.").to.be.ok
  serializedMessage = calledWith[0]
  JSON.parse(serializedMessage)

describe 'logging', ->
  beforeEach ->
    @timestamp = moment.utc('2016-02-15T12:34:56.789Z')
    @output =
      log: sinon.spy()
    @log = new Logger
      now: => @timestamp
      output: @output
      events: {
        'startup': 'startup'
        'exception': 'exception'
        'lunchtime': 'lunch time'
      }

  it 'should log all required components', ->
    @log.exception.error()

    contents = fromLogMessage(@output.log)

    expect(contents).to.have.property 'timestamp', '2016-02-15T12:34:56.789Z'
    expect(contents).to.have.property 'event_type', 'exception'
    expect(contents).to.have.property 'severity', 'ERROR'

  it 'should pass on all properties that are passed in', ->
    extra_properties =
      correlation_id: '126bb6fa-28a2-470f-b013-eefbf9182b2d'
      request:
        method: 'GET'
      response:
        status: 200
    @log.exception.error extra_properties

    contents = fromLogMessage(@output.log)

    expect(contents.correlation_id).to.equal '126bb6fa-28a2-470f-b013-eefbf9182b2d'
    expect(contents.request.method).to.equal 'GET'
    expect(contents.response.status).to.equal 200

  it 'can be scoped with specific properties', ->
    scoped_properties =
      service: 'object creation factory maker'
      something: 'shiny'
    extra_properties =
      foo: 'bar'

    log = @log.with(scoped_properties)
    log.lunchtime.error extra_properties

    contents = fromLogMessage(@output.log)

    expect(contents).to.have.property 'service', 'object creation factory maker'
    expect(contents).to.have.property 'something', 'shiny'
    expect(contents).to.have.property 'foo', 'bar'

  it 'can be scoped further with additional properties', ->
    scoped_properties =
      beverage: 'orange soda'
    additional_scoped_properties =
      sandwich: 'noodle'
    extra_properties =
      soup: 'laksa'

    log = @log.with(scoped_properties).with(additional_scoped_properties)
    log.lunchtime.error extra_properties

    contents = fromLogMessage(@output.log)

    expect(contents).to.have.property 'beverage', 'orange soda'
    expect(contents).to.have.property 'sandwich', 'noodle'
    expect(contents).to.have.property 'soup', 'laksa'

  it 'ensures scoping a second time does not affect the original logger', ->
    scoped_properties =
      cat: 'ginger'
    additional_scoped_properties =
      dog: 'poodle'
    extra_properties =
      fish: 'with chips'

    log = @log.with(scoped_properties)
    rescoped_log = log.with(additional_scoped_properties)
    log.lunchtime.error extra_properties

    contents = fromLogMessage(@output.log)

    expect(contents).to.not.have.property 'dog'
    expect(contents).to.have.property 'cat', 'ginger'
    expect(contents).to.have.property 'fish', 'with chips'

  it 'converts strings into an object', ->
    @log.startup.info 'Hello!'

    contents = fromLogMessage(@output.log)

    expect(contents).to.have.property 'message', 'Hello!'

  ['debug', 'info', 'warning', 'error', 'critical'].forEach (severity) ->
    it "should accept #{severity} as a severity", ->
      @log.startup[severity]()

      contents = fromLogMessage(@output.log)

      expect(contents).to.have.property 'severity'
      .that.equals severity.toUpperCase()
