require 'spec_helper'
require 'mail'

describe Padrino::Contrib::ExceptionNotifier do
  before :each do
    mock_app {
      register Padrino::Rendering
      register Padrino::Mailer
      set :delivery_method, test: { } # Resembles a more realistic SMTP configuration
      register Padrino::Contrib::ExceptionNotifier
      set :exceptions_views, Padrino.root('views/exception_notifier')
      set :exceptions_page, 'errors.erb'

      get(:boom) { 420 / 0 }
    }
  end

  def last_email
    Mail::TestMailer.deliveries.last
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
      get '/boom', foo: 'bar'
      expect(last_email.body).to match /"foo" => "bar"/
    end

    it 'filters out password and password_confirmation params' do
      get '/boom', password: 'super_secret', password_confirmation: 'super_secret'
      expect(last_email.body).to match /"password" => \[FILTERED\]/
      expect(last_email.body).to match /"password_confirmation" => \[FILTERED\]/
    end

    it 'allows customizing filtered params' do
      @app.set :exceptions_params_filter, [ 'foo' ]
      get '/boom', foo: 'bar'
      expect(last_email.body).to match /"foo" => \[FILTERED\]/
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
