module PT::Flow
  class StoryBranch < Branch
    require 'i18n'
    require 'active_support/core_ext/string/inflections'

    def initialize(task)
      super("#{Branch.current.target}.#{task.name.parameterize[0..60]}.#{task.id}")
    end

  end
end
