module FixtureMacros
  def fixture_file(filename)
    File.new(fixture_file_path(filename))
  end

  def fixture_file_path(filename)
    File.join(File.dirname(__FILE__), '..', 'fixtures', filename)
  end
end

RSpec.configure do |config|
  config.include(FixtureMacros)
end
