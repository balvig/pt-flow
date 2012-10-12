RSpec.configure do |config|
  dummy_path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'dummy')

  config.before(:each) do
    FileUtils.rm_rf(dummy_path) if Dir.exists?(dummy_path)
    Dir.mkdir(dummy_path)
    Dir.chdir(dummy_path)
    system('git init .')
    system('touch dummy.txt')
    system('git add .')
    system('git commit -m"init commit"')
  end

end
