require 'ello/cas'
require 'rake'

# Probably overkill and should find a better way to accomplish this in the future. 

load File.expand_path("../../tasks/cas.rake", __FILE__)

RSpec.configure do |config|
  config.before(:all) do
  	Rake::Task['cas'].invoke('schema/schema_streams.cql')
  end
end