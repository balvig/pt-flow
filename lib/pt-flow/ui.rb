class PT::Flow::UI < PT::UI

  def list
    @params[0] ||= 'all'
    super
  end

  def checkout
    tasks = @client.get_work(@project)
    table = PT::TasksTable.new(tasks)
    task = table[@params[0].to_i]
    result = @client.assign_task(@project, task, owner)
    if result.errors.any?
      error(result.errors.errors)
    else
      congrats("Task assigned to #{owner}, checking out new branch!")
    end
    `git checkout -B #{task.id}`
  end

  private

  def owner
    @local_config[:user_name]
  end
end
