class BitbucketGit < SystemCommand

  def self.scm_class
    Repository::Git
  end

  # Fetches updates from the remote repository
  def self.update_repository(local_url, cmd="git")
    command = cmd + " --git-dir='#{local_url}' fetch origin"
    if exec(command)
      command = cmd + " --git-dir='#{local_url}' fetch origin '+refs/heads/*:refs/heads/*'"
      exec(command)
    end
  end

  # Clone repository from Bitbucket
  def self.clone_repository(path, local_url, cmd="git")
    remote_url = "git@bitbucket.org:#{path}.git"
    command = cmd + " clone --mirror #{remote_url} #{local_url}"
    return exec(command)
  end 

end
