require 'json'
require 'stringio'
require_relative '../lib/microservice_logging'

RSpec.describe MicroserviceLogger do
  let(:a_time) { Time.now }
  let(:clock) { class_double(Time) }
  let(:output) { StringIO.new }
  subject do
    MicroserviceLogger.new(service_name: 'rainbow-dash',
                           clock: clock,
                           output: output)
  end

  before do
    allow(clock).to receive(:now).and_return(a_time)
  end

  context 'event types' do
    let(:log_severities) { [:debug, :info, :warning, :error, :critical] }

    [:http_request, :applejack, :startup, :exception].each do |event_type|
      it "supports #{event_type}" do
        log_severities.each do |severity|
          expect(subject.public_send(event_type)).to respond_to(severity)
        end
      end
    end
  end

  it 'should log all required components' do
    allow(clock).to receive(:now).and_return(
      Time.utc(2016, 2, 17, 12, 34, 56, 789_000)
    )

    subject.startup.info({})

    contents = JSON.parse(output.string)
    expect(contents).to eq(
      'service' => 'rainbow-dash',
      'timestamp' => '2016-02-17T12:34:56.789Z',
      'event_type' => 'startup',
      'severity' => 'INFO'
    )
  end

  it 'should print a new line after the JSON' do
    subject.startup.info({})

    expect(output.string).to end_with("}\n")
  end

  it 'should pass on all properties that are passed in' do
    extra_properties = {
      'correlation_id' => '6889828a-6708-46f7-beec-870cf7b4ab6f',
      'request' => {
        'method' => 'GET'
      },
      'response' => {
        'status_code' => 200
      }
    }

    subject.http_request.info extra_properties

    contents = JSON.parse(output.string)
    expect(contents).to include(extra_properties)
  end

  it 'can be scoped with specific properties' do
    scoped_properties = {
      'something' => 'blue'
    }
    extra_properties = {
      'something_else' => 'red'
    }

    scoped_log = subject.with(scoped_properties)
    scoped_log.http_request.error extra_properties

    contents = JSON.parse(output.string)
    expect(contents)
      .to include(scoped_properties)
      .and(include(extra_properties))
  end

  it 'should accept DEBUG as a severity' do
    subject.startup.debug({})

    contents = JSON.parse(output.string)
    expect(contents).to include('severity' => 'DEBUG')
  end

  it 'should accept INFO as a severity' do
    subject.startup.info({})

    contents = JSON.parse(output.string)
    expect(contents).to include('severity' => 'INFO')
  end

  it 'should accept WARNING as a severity' do
    subject.startup.warning({})

    contents = JSON.parse(output.string)
    expect(contents).to include('severity' => 'WARNING')
  end

  it 'should accept ERROR as a severity' do
    subject.startup.error({})

    contents = JSON.parse(output.string)
    expect(contents).to include('severity' => 'ERROR')
  end

  it 'should accept CRITICAL as a severity' do
    subject.startup.critical({})

    contents = JSON.parse(output.string)
    expect(contents).to include('severity' => 'CRITICAL')
  end

  it 'converts strings into an object' do
    subject.http_request.error 'Meep.'

    contents = JSON.parse(output.string)
    expect(contents).to include('message' => 'Meep.')
  end

  it 'converts any other object into a string and wraps it' do
    subject.http_request.error Time.utc(1970, 6, 12)

    contents = JSON.parse(output.string)
    expect(contents).to include('message' => '1970-06-12 00:00:00 UTC')
  end

  # Currently this is really more of a demonstration of how to use
  # the functionality, rather than an actual test. Further help
  # could be built into the library to format error objects.
  it 'writes a multi-line stack trace into a single log entry' do
    def will_throw
      1 / 0
    end
    begin
      will_throw
    rescue => bang
      extra_properties = {
        'error' => bang.class.to_s,
        'stacktrace' => bang.backtrace
      }
      subject.startup.critical(extra_properties)

      contents = JSON.parse(output.string)
      expect(contents).to include('error' => 'ZeroDivisionError')
      expect(contents['stacktrace']).to be_a(Array)
      expect(contents['stacktrace'][0]).to start_with(__FILE__)
    end
  end
end
