module PT::Flow
  class StoryBranch < Branch
    require 'active_support/inflector'

    def initialize(task)
      super("#{Branch.current.target}-#{task.id}")
    end

  end
end
