class BitbucketGit < SystemCommand

  GIT_BIN = Redmine::Configuration['scm_git_command'] || "git"

  def self.scm_class
    Repository::Git
  end

  # Fetches updates from the remote repository
  def self.update_repository(local_url)
    fetch_opts = Setting.plugin_redmine_bitbucket[:git_fetch_with_prune] ? '--prune' : ''
    command = GIT_BIN + " --git-dir='#{local_url}' fetch #{fetch_opts} origin"
    if exec(command)
      command = GIT_BIN + " --git-dir='#{local_url}' fetch #{fetch_opts} origin '+refs/heads/*:refs/heads/*'"
      exec(command)
    end
  end

  # Clone repository from Bitbucket
  def self.clone_repository(path, local_url)
    remote_url = "git@bitbucket.org:#{path}.git"
    command = GIT_BIN + " clone --mirror #{remote_url} #{local_url}"
    return exec(command)
  end 

end
