module PT::Flow
  class TasksTable < PT::TasksTable
    def self.fields
      [:name, :story_type, :current_state, :id]
    end
  end
end
