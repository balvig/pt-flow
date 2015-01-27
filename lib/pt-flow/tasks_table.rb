module PT::Flow
  class TasksTable < PT::TasksTable
    def initialize(dataset)
      @rows = dataset.map { |row| TaskRow.new(row, dataset) }
    end

    def self.fields
      [:name, :story_type, :current_state, :owned_by]
    end
  end
end
