class PT::Flow::UI < PT::UI

  def start
    tasks = @client.get_work(@project)
    table = PT::TasksTable.new(tasks)
    if @params[0]
      task = table[@params[0].to_i]
    else
      title("Available tasks in #{project_to_s}")
      task = select("Please select a task to start working on", table)
    end

    result = @client.assign_task(@project, task, owner)
    if result.errors.any?
      error(result.errors.errors)
    else
      start_task(task)
      congrats("Task assigned to #{owner}, checking out new branch!")
      `git checkout -B #{task.id}`
    end
  end

  def finish
    `git push origin #{current_branch}`
    task = PivotalTracker::Story.find(current_branch, @project.id)
    finish_task(task)
    pull_request_url = "#{github_page_url}/pull/new/#{current_branch}?title=#{task.name} [##{task.id}]&body=#{task.url}"
    `open '#{pull_request_url}'`
  end

  def deliver
    branch = @params[0] || current_branch
    `git checkout master`
    `git merge #{branch}`
    `git push origin master`
    `git push origin :#{branch}`
    `git branch -d #{branch}`
    task = PivotalTracker::Story.find(branch, @project.id)
    deliver_task(task)
  end

  private

  def github_page_url
    repo_url = `git config --get remote.origin.url`.strip
    stub = repo_url.match(/:(\S+\/\S+)\.git/)[1]
    "https://github.com/#{stub}"
  end

  def current_branch
    @current_branch ||= `git rev-parse --abbrev-ref HEAD`.strip
  end

  def owner
    @local_config[:user_name]
  end
end
