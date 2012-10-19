module PT::Flow
  class Repo
    require "github_api"
    CONFIG_PATH = ENV['HUB_CONFIG'] ||  ENV['HOME'] + '/.config/hub'

    def pull_requests
      client.pull_requests.all(user, name)
    end

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

    def client
      @client ||= Github.new(oauth_token: oauth_token)
    end

    def oauth_token
      @oauth_token ||= YAML.load(File.read(CONFIG_PATH)).values.flatten.first['oauth_token']
    end

  end
end
