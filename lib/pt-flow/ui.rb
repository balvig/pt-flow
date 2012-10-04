class PT::Flow::UI < PT::UI

  def setup
    `git-tracker install`
    message 'git-tracker ready to add story numbers to commits'
    congrats 'All done!'
  end

  def load_local_config
    config = super
    config[:github_url] = ask "What is the url for the Github repo?"
    save_config(config, LOCAL_CONFIG_PATH)
    config
  end

  def list
    @params[0] ||= 'all'
    super
  end

  def checkout
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
      congrats("Task assigned to #{owner}, checking out new branch!")
    end

    `git checkout -B #{task.id}`
  end

  def request
    `git push origin #{current_branch}`
    task = PivotalTracker::Story.find(current_branch, @project.id)
    `open '#{github_url}/pull/new/#{current_branch}?title=#{task.name} [##{task.id}]'`
  end

  def merge
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

  def github_url
    'https://github.com/balvig/pt-flow'
  end

  def current_branch
    @current_branch ||= `git rev-parse --abbrev-ref HEAD`.strip
  end

  def owner
    @local_config[:user_name]
  end
end
