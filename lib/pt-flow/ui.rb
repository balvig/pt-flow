class PT::Flow::UI < PT::UI
  def my_work #default command
    help
  end

  def start
    tasks = @client.get_work(@project)
    table = PT::TasksTable.new(tasks)
    title("Available tasks in #{project_to_s}")
    task = select("Please select a task to start working on", table)

    estimate_task(task, ask("How many points do you estimate for it? (#{@project.point_scale})")) if task.estimate && task.estimate < 0
    assign_task(task, @local_config[:user_name])
    start_task(task)
    run("git checkout -B #{current_target}-#{task.id}")
  end

  def finish
    run("git push origin #{current_branch}")
    task = PivotalTracker::Story.find(current_task_id, @project.id)
    title = task.name.gsub('"',"'")
    run("hub pull-request -b #{current_target} \"#{title}\"")
    finish_task(task)
  end

  def deliver
    run('git fetch')
    run("git checkout #{current_target}")
    run("git pull --rebase origin #{current_target}")
    run("git merge #{current_branch}")
    run("git push origin #{current_target}")
    run("git push origin :#{current_branch}")
    run("git branch -d #{current_branch}")
    task = PivotalTracker::Story.find(current_task_id, @project.id)
    deliver_task(task)
  end

  def cleanup
    # Update our list of remotes
    run("git fetch")
    run("git remote prune origin")

    # Remove local branches fully merged with origin/master
    run("git branch --merged origin/master | grep -v 'master$' | xargs git branch -D")

    # Remove remote branches fully merged with origin/master
    run("git branch -r --merged origin/master | sed 's/ *origin\\///' | grep -v 'master$' | xargs -I% git push origin :%")

    congrats('All clean!')
  end

  def help
    if ARGV[0] && ARGV[0] != 'help'
      message("Command #{ARGV[0]} not recognized. Showing help.")
    end

    title("Command line usage")
    puts("flow start                             # start working on a story")
    puts("flow finish                            # finish a story and create a pull request")
    puts("flow deliver                           # merge current story branch and clean up")
    puts("flow cleanup                           # deleted merged local branches and prune origin")
  end

  private

  def assign_task(task, owner)
    result = @client.assign_task(@project, task, owner)
    if result.errors.any?
      error(result.errors.errors)
    else
      congrats("Task assigned to #{owner}")
    end
  end

  def github_page_url
    repo_url = `git config --get remote.origin.url`.strip
    stub = repo_url.match(/:(\S+\/\S+)\.git/)[1]
    "https://github.com/#{stub}"
  end

  def current_branch
    @current_branch ||= `git rev-parse --abbrev-ref HEAD`.strip
  end

  def current_target
    current_branch.sub(current_task_id, '').chomp('-')
  end

  def current_task_id
    current_branch[/\d+$/] || ''
  end

  def run(command)
    title(command)
    error("Error running: #{command}") unless system(command)
  end

  def error(*msg)
    super
    exit(false)
  end

end
