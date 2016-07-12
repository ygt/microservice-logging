var Logger, log, service_logger;

Logger = require('./logger');

log = new Logger({
  now: Date.now,
  output: console
})

service_logger = log.with({
  service: 'my super service'
});

log.startup.error({
  message: "Emergency! There's an Emergency going on"
});

log.httpRequest.info({
  correlation_id: '126bb6fa-28a2-470f-b013-eefbf9182b2d',
  request: { method: 'GET' },
  response: { status: 200 }
});
