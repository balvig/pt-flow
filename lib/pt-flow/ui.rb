module PT::Flow
  class UI < PT::UI

    def initialize(command, args = [])
      super [command] + (args)
    end

    def start
      @options = Trollop::options(@params.dup) do
        opt :filter, 'Allow filtering tasks', type: :string
      end

      if @params[0] && !@params[0].start_with?('--')
        task = create
      else
        filter = filters[@options[:filter]] || { current_state: 'unstarted,started' }
        table = TasksTable.new @project.stories.all(filter)
        title("Available tasks in #{project_to_s}")
        task = select("Please select a task to start working on", table)
      end
      estimate_task(task, ask("How many points do you estimate for it? (#{@project.point_scale})")) if task.estimate && task.estimate < 0
      assign_task(task, user_name)
      start_task(task)
      run("git checkout -b #{Branch.from_task(task)}")
    end

    def create
      name = @params[0] || ask("Name for the new story:")
      types = { 'c' => 'chore', 'b' => 'bug', 'f' => 'feature' }
      task_type = types[ask('Type? (c)hore, (b)ug, (f)eature')]
      task = @project.stories.create(name: name, requested_by: user_name, story_type: task_type)
      if task.errors.any?
        error(task.errors.errors)
      else
        congrats("#{task_type} created: #{task.url}")
        task
      end
    end

    def finish
      @options = Trollop::options(@params.dup) do
        opt :deliver, 'Merge branch automatically'
        opt :wip, 'submits [WIP] pull request'
      end

      run "git push origin #{branch} -u"
      if @options[:deliver]
        deliver!
      elsif @options[:wip]
        open_url pull_request_url('[WIP]')
      else
        finish_task current_task
        open_url pull_request_url
      end
    end

    def cleanup
      title("Cleaning merged story branches for [#{branch.target}]")

      # Update our list of remotes
      run("git fetch")
      run("git remote prune origin")

      # Only clean out merged story branches for current topic
      filter = "^ *#{branch.target}.\\+[0-9]\\+$"

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

      def current_task
        PivotalTracker::Story.find(branch.task_id, @project.id)
      end

      def task_title
        task_title = current_task.name.gsub('"',"'") + " [Delivers ##{current_task.id}]"
        task_title = 'Bugfix: ' + task_title if current_task.story_type == 'bug'
        task_title
      end

      def pull_request_url(prefix = nil)
        title = URI.escape "#{prefix} #{task_title}".strip
        repo.url + "/compare/#{branch.target}...#{branch}?expand=1&title=#{title}"
      end

      def deliver!
        run "hub pull-request -b #{branch.target} -h #{repo.user}:#{branch} -m \"#{task_title}\""
        finished_branch = branch
        title = task_title
        run "git checkout #{finished_branch.target}"
        run "git pull"
        run "git merge #{finished_branch} --no-ff -m \"#{title}\""
        run "git push origin #{finished_branch.target}"
      end

      def open_url(url)
        if ENV['BROWSER'] == 'echo'
          title url
        else
          run "open \"#{url}\""
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

      def filters
        {
          'icebox' => { current_state: 'unscheduled' },
          'me' => { current_state: 'unscheduled,unstarted,started', owner: user_name }
        }
      end

      def user_name
        @local_config[:user_name]
      end
  end
end
