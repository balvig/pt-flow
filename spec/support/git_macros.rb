module GitMacros
  def current_branch
    `git rev-parse --abbrev-ref HEAD`.strip
  end

  def remote_branches
    `git branch -r`.strip.split("\n").map(&:strip)
  end
end

RSpec.configure do |config|
  config.include(GitMacros)
end
