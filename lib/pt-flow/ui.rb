module PT::Flow
  class UI < PT::UI

    def initialize(command, args = [])
      super [command] + (args)
    end

    def start
      if @params[0]
        task = create
      else
        table = TasksTable.new(@client.get_work(@project))
        title("Available tasks in #{project_to_s}")
        task = select("Please select a task to start working on", table)
      end
      estimate_task(task, ask("How many points do you estimate for it? (#{@project.point_scale})")) if task.estimate && task.estimate < 0
      assign_task(task, @local_config[:user_name])
      start_task(task)
      run("git checkout -b #{Branch.from_task(task)}")
    end

    def create
      name = @params[0] || ask("Name for the new story:")
      types = { 'c' => 'chore', 'b' => 'bug', 'f' => 'feature' }
      task_type = types[ask('Type? (c)hore, (b)ug, (f)eature')]
      task = @project.stories.create(name: name, requested_by: @local_config[:user_name], story_type: task_type)
      if task.errors.any?
        error(task.errors.errors)
      else
        congrats("#{task_type} created: #{task.url}")
        task
      end
    end

    def finish
      run("git push origin #{branch} -u")
      task = PivotalTracker::Story.find(branch.task_id, @project.id)
      title = task.name.gsub('"',"'") + " [Delivers ##{task.id}]"

      run("hub pull-request -b #{branch.target} -h #{repo.user}:#{branch} -m \"#{title}\"")
      finish_task(task)
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
