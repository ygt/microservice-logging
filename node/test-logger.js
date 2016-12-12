const {describe, it, beforeEach} = require('mocha')
const {expect} = require('chai')
const sinon = require('sinon')
const moment = require('moment')
const Logger = require('./logger')

const fromLogMessage = function (output, {atIndex = 0} = {}) {
  const calledWith = output.args[atIndex]
  expect(calledWith, `The caller wrote to the output ${output.args.length} times.`).to.be.ok
  const serializedMessage = calledWith[0]
  return JSON.parse(serializedMessage)
}

describe('logging', function () {
  beforeEach(function () {
    this.timestamp = moment.utc('2016-02-15T12:34:56.789Z')
    this.output = sinon.spy()
    this.log = new Logger({
      now: () => this.timestamp,
      output: this.output,
      events: {
        'startup': 'startup',
        'exception': 'exception',
        'lunchtime': 'lunch time'
      }
    })
  })

  it('should log all required components', function () {
    this.log.exception.error()

    const contents = fromLogMessage(this.output)

    expect(contents).to.have.property('timestamp', '2016-02-15T12:34:56.789Z')
    expect(contents).to.have.property('event_type', 'exception')
    expect(contents).to.have.property('severity', 'ERROR')
  })

  it('should pass on all properties that are passed in', function () {
    const extraProperties = {
      correlation_id: '126bb6fa-28a2-470f-b013-eefbf9182b2d',
      request: {
        method: 'GET'
      },
      response: {
        status: 200
      }
    }
    this.log.exception.error(extraProperties)

    const contents = fromLogMessage(this.output)

    expect(contents.correlation_id).to.equal('126bb6fa-28a2-470f-b013-eefbf9182b2d')
    expect(contents.request.method).to.equal('GET')
    expect(contents.response.status).to.equal(200)
  })

  it('can be scoped with specific properties', function () {
    const scopedProperties = {
      service: 'object creation factory maker',
      something: 'shiny'
    }
    const extraProperties = {
      foo: 'bar'
    }

    const log = this.log.with(scopedProperties)
    log.lunchtime.error(extraProperties)

    const contents = fromLogMessage(this.output)

    expect(contents).to.have.property('service', 'object creation factory maker')
    expect(contents).to.have.property('something', 'shiny')
    expect(contents).to.have.property('foo', 'bar')
  })

  it('can be scoped further with additional properties', function () {
    const scopedProperties = {
      beverage: 'orange soda'
    }
    const additionalScopedProperties = {
      sandwich: 'noodle'
    }
    const extraProperties = {
      soup: 'laksa'
    }

    const log = this.log.with(scopedProperties).with(additionalScopedProperties)
    log.lunchtime.error(extraProperties)

    const contents = fromLogMessage(this.output)

    expect(contents).to.have.property('beverage', 'orange soda')
    expect(contents).to.have.property('sandwich', 'noodle')
    expect(contents).to.have.property('soup', 'laksa')
  })

  it('ensures scoping a second time does not affect the original logger', function () {
    const scopedProperties = {
      cat: 'ginger'
    }
    const additionalScopedProperties = {
      dog: 'poodle'
    }
    const extraProperties = {
      fish: 'with chips'
    }

    const log = this.log.with(scopedProperties)
    log.with(additionalScopedProperties)

    log.lunchtime.error(extraProperties)

    const contents = fromLogMessage(this.output)

    expect(contents).to.not.have.property('dog')
    expect(contents).to.have.property('cat', 'ginger')
    expect(contents).to.have.property('fish', 'with chips')
  })

  it('converts strings into an object', function () {
    this.log.startup.info('Hello!')

    const contents = fromLogMessage(this.output)

    expect(contents).to.have.property('message', 'Hello!')
  })

  ; ['debug', 'info', 'warning', 'error', 'critical'].forEach(severity => {
    it(`should accept ${severity} as a severity`, function () {
      this.log.startup[severity]()

      const contents = fromLogMessage(this.output)

      expect(contents).to.have.property('severity')
        .that.equals(severity.toUpperCase())
    })
  })

  it('allows just passing `console` too, for backwards compatibility', function () {
    const fakeConsole = new FakeConsole(this.output)
    const log = new Logger({
      now: () => this.timestamp,
      output: fakeConsole,
      events: {
        'startup': 'startup',
        'exception': 'exception',
        'lunchtime': 'lunch time'
      }
    })

    log.exception.info({foo: 'bar'})

    const contents = fromLogMessage(this.output)

    expect(contents).to.have.property('foo', 'bar')
  })

  class FakeConsole {
    constructor (output) {
      this.output = output
    }

    log (...args) {
      this.output(...args)
    }
  }
})
