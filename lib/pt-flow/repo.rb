module PT::Flow
  class Repo

    def user
      path.split('/').first
    end

    def name
      path.split('/').last
    end

    private

    def path
      @path ||= `git config --get remote.origin.url`.strip.match(/:(\S+\/\S+)\.git/)[1]
    end

  end
end
