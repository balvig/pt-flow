module PT::Flow
  class UI < PT::UI

    def my_work #default command
      super
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
      run("git checkout -b #{Branch.from_task(task)}")
    end

    def finish
      run("git push origin #{branch}")
      task = PivotalTracker::Story.find(branch.task_id, @project.id)
      title = task.name.gsub('"',"'") + " [##{task.id}]"

      run("hub pull-request -b #{branch.target} -h #{repo.user}:#{branch} \"#{title}\"")
      run("git checkout #{branch.target}")
      finish_task(task)
    end

    def deliver
      source = branch
      target = branch.target
      run('git fetch')
      run("git checkout #{target}")
      run("git pull --rebase origin #{target}")
      run("git merge #{source}")
      run("git push origin #{target}")
      run("git push origin :#{source}")
      run("git branch -d #{source}")
      task = PivotalTracker::Story.find(source.task_id, @project.id)
      deliver_task(task)
    end

    def review
      table = PullRequestsTable.new(repo.pull_requests)
      pull_request = select("Please select a pull request to review", table)
      run("git fetch")
      run("git checkout #{pull_request.head.ref}")
      run("open #{pull_request.html_url}/files")
    rescue Github::Error::Unauthorized => e
      error("Error from github: #{e.message}")
    end

    def cleanup
      title("Cleaning merged story branches for [#{branch.target}]")

      # Update our list of remotes
      run("git fetch")
      run("git remote prune origin")

      # Only clean out merged story branches for current topic
      filter = "#{branch.target}.\\+[0-9]\\+$"

      # Remove local branches fully merged with origin/current_target
      run("git branch --merged origin/#{branch.target} | grep '#{filter}' | xargs git branch -D")

      # Remove remote branches fully merged with origin/master
      run("git branch -r --merged origin/#{branch.target} | sed 's/ *origin\\///' | grep '#{filter}' | xargs -I% git push origin :%")

      congrats("Deleted branches merged with [#{branch.target}]")
    end

    def help
      if ARGV[0] && ARGV[0] != 'help'
        message("Command #{ARGV[0]} not recognized. Showing help.")
      end

      title("Command line usage")
      puts("flow start                             # start working on a story")
      puts("flow finish                            # finish a story and create a pull request")
      puts("flow review                            # review a pull request")
      puts("flow deliver                           # merge current branch and clean up")
      puts("flow cleanup                           # deleted merged local/remote branches and prune origin")
    end

    private

    def branch
      @branch ||= Branch.current
    end

    def repo
      @repo ||= Repo.new
    end

    def assign_task(task, owner)
      result = @client.assign_task(@project, task, owner)
      if result.errors.any?
        error(result.errors.errors)
      else
        congrats("Task assigned to #{owner}")
      end
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
end
