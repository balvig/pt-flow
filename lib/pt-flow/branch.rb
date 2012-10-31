module PT::Flow
  class Branch
    require 'i18n'
    require 'active_support/core_ext/string/inflections'

    attr_accessor :name

    def self.current
      new(`git rev-parse --abbrev-ref HEAD`.strip)
    end

    def self.from_task(task)
      new("#{current.target}.#{task.name.parameterize[0..50]}.#{task.id}")
    end

    def initialize(name)
      @name = name
    end

    def target
      name.split('.').first
    end

    def task_id
      name[/\d+$/] || ''
    end

    def to_s
      name
    end

  end
end
