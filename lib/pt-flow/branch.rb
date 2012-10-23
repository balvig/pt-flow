module PT::Flow
  class Branch
    require 'active_support/inflector'

    def

    def initialize(target, story)
      @target = target
      @story = story
    end

    def target

    end
    def

    def current_target
      current_branch.sub(current_task_id, '').chomp('-')
    end


    def name
      "#{target}.#{story.name.parameterize[0..80]}.#{story.id}"
    end

  end
end
