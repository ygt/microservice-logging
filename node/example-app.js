const Logger = require('./logger')

const log = new Logger({
  now: Date.now,
  output: console,
  events: {
    startup: 'startup',
    httpRequest: 'HTTP request',
    database: 'database'
  }
}).with({service: 'my super service'})

log.startup.info({
  message: 'Ready to go.',
  port: 8080
})

const requestLog = log.with({correlation_id: '126bb6fa-28a2-470f-b013-eefbf9182b2d'})
requestLog.database.error({
  message: 'Connection failed.'
})
requestLog.httpRequest.info({
  request: {method: 'GET'},
  response: {status: 500}
})
