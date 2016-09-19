const Logger = require('./logger')

const log = new Logger({
  now: Date.now,
  output: console,
  events: {
    startup: 'startup',
    httpRequest: 'HTTP request'
  }
}).with({service: 'my super service'})

log.startup.error({
  message: "Emergency! There's an Emergency going on"
})

const requestLog = log.with({correlation_id: '126bb6fa-28a2-470f-b013-eefbf9182b2d'})
requestLog.httpRequest.info({
  request: {method: 'GET'},
  response: {status: 200}
})
