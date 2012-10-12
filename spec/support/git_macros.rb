module GitMacros
  def current_branch
    `git rev-parse --abbrev-ref HEAD`.strip
  end
end

RSpec.configure do |config|
  config.include(GitMacros)
end
