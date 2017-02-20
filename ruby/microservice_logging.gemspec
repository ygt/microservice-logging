Gem::Specification.new do |s|
  s.name        = 'microservice_logging'
  s.version     = '1.0.0'
  s.date        = '2016-10-06'
  s.summary     = 'Structured logging for microservices'
  s.description = 'A library aiming to help microservice developers with producing structured JSON logs suitable for use with StackDriver, ElasticSearch etc.'
  s.authors     = ['@sleepyfox']
  s.email       = 'developers@yourgolftravel.com'
  s.files       = ['lib/microservice_logging.rb', 'lib/json_event_logger.rb']
  s.homepage    =
    'https://github.com/ygt/microservice-logging/'
  s.license = 'MIT'
end
