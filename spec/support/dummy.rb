RSpec.configure do |config|
  fixtures_path = File.expand_path('../../fixtures', __FILE__)
  dummy_path = File.join(fixtures_path, 'dummy')
  origin_path = File.join(fixtures_path, 'origin.git')

  config.before(:each) do
    [dummy_path, origin_path].each do |path|
      FileUtils.rm_rf(path) if Dir.exists?(path)
      FileUtils.mkdir_p(path)
    end
    Dir.chdir(dummy_path)
    system('git init .')
    system('touch dummy.txt')
    system('git add .')
    system('git commit -m"init commit"')
    Dir.chdir(origin_path)
    system('git init . --bare')
    Dir.chdir(dummy_path)
    system("git remote add origin file://#{origin_path}")
    system("git push -u origin master")
  end

end
