require 'spec_helper'
require 'mail'

describe Padrino::Contrib::ExceptionNotifier do
  before :each do
    mock_app {
      register Padrino::Helpers
      register Padrino::Mailer
      set :delivery_method, :test => { } # Resembles a more realistic SMTP configuration
      register Padrino::Contrib::ExceptionNotifier
      set :exceptions_views, Padrino.root('views/exception_notifier')
      set :exceptions_page, 'errors.erb'
      set :exceptions_layout, "layout.erb"

      get(:boom) { 420 / 0 }
    }
  end

  def last_email
    Mail::TestMailer.deliveries.last
  end

  def logged_report
    @log.string
  end

  before :each do
    @log = StringIO.new
    log = Logger.new(@log)
    @app.send(:define_method, :logger) { log }
  end

  context 'when an exception is raised' do
    it 'sends a notification email' do
      expect { get '/boom' }.to change { Mail::TestMailer.deliveries }
      expect(last_email.subject).to eq '[Exception] ZeroDivisionError - divided by 0'
      expect(last_email.to).to eq [ 'errors@localhost.local' ]
      expect(last_email.from).to eq [ 'foo@bar.local' ]
    end

    it 'allows customizing the email subject' do
      @app.set :exceptions_subject, 'Custom subject'
      get '/boom'
      expect(last_email.subject).to eq '[Custom subject] ZeroDivisionError - divided by 0'
    end

    it 'allows customizing the recipients' do
      @app.set :exceptions_to, 'Foo <foo@example.com>, bar@example.com'
      get '/boom'
      expect(last_email.to).to eq [ 'foo@example.com', 'bar@example.com' ]
    end

    it 'allows customizing the sender' do
      @app.set :exceptions_from, 'Foo <foo@example.com>'
      get '/boom'
      expect(last_email.from).to eq [ 'foo@example.com' ]
    end

    it 'sends the request params' do
      get '/boom', :foo => 'bar'
      expect(last_email.body).to match /"foo" => "bar"/
    end

    it 'filters out password and password_confirmation params' do
      get '/boom', :password => 'super_secret', :password_confirmation => 'super_secret'
      expect(last_email.body).to match /"password" => \[FILTERED\]/
      expect(last_email.body).to match /"password_confirmation" => \[FILTERED\]/
    end

    it 'allows customizing filtered params' do
      @app.set :exceptions_params_filter, [ 'foo' ]
      get '/boom', :foo => 'bar'
      expect(last_email.body).to match /"foo" => \[FILTERED\]/
    end

    it 'filters params nested in hashes and arrays' do
      get '/boom', :user => { :name => 'joe', :password => 'super_secret' },
                   :rows => [ { :password_confirmation => 'super_secret' } ]
      expect(last_email.body.to_s).to include '"joe"'
      expect(last_email.body.to_s).not_to include 'super_secret'
    end

    it 'filters keys that contain a filtered word, and regexp filters' do
      @app.set :exceptions_params_filter, [ 'password', /\Apin\z/i ]
      get '/boom', :current_password => 'super_secret', :PIN => '1234', :pinned => 'yes'
      expect(last_email.body.to_s).not_to include 'super_secret'
      expect(last_email.body.to_s).not_to include '1234'
      expect(last_email.body.to_s).to include '"yes"'
    end

    it 'filters posted form fields in the params and the env' do
      @app.post(:boom) { 420 / 0 }
      post '/boom', :user => { :password => 'form_secret', :name => 'joe' }
      expect(last_email.body.to_s).not_to include 'form_secret'
      expect(last_email.body.to_s).to include '"joe"'
    end

    it 'reports requests carrying bytes that are not valid UTF-8' do
      get '/boom?%FF=1&password=super_secret', {}, 'HTTP_USER_AGENT' => "Agent\xFF".b
      expect(last_response.status).to eq 500
      expect(last_email.body.to_s).to include 'QUERY_STRING: %FF=1&password=[FILTERED]'
      expect(last_email.body.to_s).not_to include 'super_secret'
    end

    it 'does not change the params seen by the application' do
      seen = []
      @app.get(:capture) { seen << params; 420 / 0 }
      get '/capture', :user => { :password => 'super_secret' }
      expect(seen.first['user']['password']).to eq 'super_secret'
    end

    it 'leaves cookies, credentials and session data out of the report' do
      @app.enable :sessions
      @app.set :session_secret, 'x' * 64
      @app.get(:login) { session[:user_id] = 'session_value_42'; 'ok' }
      @app.get(:session_boom) { session[:user_id]; 420 / 0 }
      get '/login'
      set_cookie 'remember_me=cookie_secret'
      get '/session_boom', { :password => 'query_secret', :page => '2' },
          'HTTP_AUTHORIZATION' => 'Bearer auth_secret',
          'HTTP_X_API_TOKEN' => 'header_secret',
          'HTTP_USER_AGENT' => 'SpecAgent/1.0'
      [ email_body = last_email.body.to_s, logged_report ].each do |report|
        expect(report).not_to include 'cookie_secret'
        expect(report).not_to include 'auth_secret'
        expect(report).not_to include 'header_secret'
        expect(report).not_to include 'query_secret'
        expect(report).not_to include 'session_value_42'
        expect(report).not_to include 'x' * 64
      end
      expect(logged_report).to include 'PATH_INFO: /session_boom'
      expect(email_body).to include 'REQUEST_METHOD: GET'
      expect(email_body).to include 'PATH_INFO: /session_boom'
      expect(email_body).to include 'HTTP_USER_AGENT: SpecAgent/1.0'
      expect(email_body).to include 'QUERY_STRING: password=[FILTERED]&page=2'
      expect(email_body).to include 'ZeroDivisionError - divided by 0'
      expect(email_body).to match /exception_notifier_spec\.rb:\d+/
    end

    it 'renders an error page' do
      get '/boom'
      expect(last_response.status).to eq 500
      expect(last_response.body).to eq "Exceptions layout\n500"
    end

    it 'allows customizing the error layout' do
      @app.set :exceptions_layout, nil
      get '/boom'
      expect(last_response.body).to eq '500'
    end

    it 'requires a view to be configured for the error page' do
      @app.instance_eval { undef :exceptions_page }
      expect { get '/boom' }.to raise_exception NoMethodError
    end
  end

  context 'when a 404 is returned' do
    it 'renders an error page' do
      get '/not_found'
      expect(last_response.status).to eq 404
      expect(last_response.body).to eq "Exceptions layout\n404"
    end

    it 'allows customizing the error layout' do
      @app.set :exceptions_layout, nil
      get '/not_found'
      expect(last_response.body).to eq '404'
    end

    it 'requires a view to be configured for the error page' do
      @app.instance_eval { undef :exceptions_page }
      expect { get '/not_found' }.to raise_exception NoMethodError
    end
  end
end
