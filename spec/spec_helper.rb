require 'bundler'
require 'pt-flow'

PT::UI.send(:remove_const, :GLOBAL_CONFIG_PATH)
PT::UI.send(:remove_const, :LOCAL_CONFIG_PATH)
PT::UI::GLOBAL_CONFIG_PATH = File.join(File.dirname(__FILE__), 'fixtures', 'global_config.yml')
PT::UI::LOCAL_CONFIG_PATH = File.join(File.dirname(__FILE__), 'fixtures', 'local_config.yml')

RSpec.configure do |config|
  config.mock_with :rspec
end
