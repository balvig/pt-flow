module PT::Flow
  class Branch

    attr_accessor :name

    def self.current
      new(`git rev-parse --abbrev-ref HEAD`.strip)
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
