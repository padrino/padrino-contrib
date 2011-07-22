require 'spec_helper'

describe 'Autoload' do

  Dir[File.expand_path('./lib/**/*.rb')].each do |file|
    next if file =~ /orm/ # orm extensions must be required by hand.
    next if file =~ /padrino-contrib\.rb$/ # skip main file

    klass = file.gsub(File.expand_path("./lib"), '').
                 gsub(/^\//, '').
                 gsub(/\.rb/, '').
                 gsub(/(^.)/) { $1.upcase }.
                 gsub(/\/|-/, "::").
                 gsub(/_(.)/) { $1.upcase }.
                 gsub(/::(.)/) { "::" + $1.upcase }.
                 gsub(/version/i, 'VERSION') # this is a constant

    it(klass) { eval("#{klass}").should be_true }
  end
end