class BitbucketHg < SystemCommand

  def self.scm_class
    Repository::Mercurial
  end

  # Fetches updates from the remote repository
  def self.update_repository(local_url, cmd="hg")
    command = cmd + " --repository '#{local_url}' pull"
    exec(command)
  end

  # Clone repository from Bitbucket
  def self.clone_repository(path, local_url, cmd="hg")
    remote_url = "ssh://hg@bitbucket.org/#{path}"
    command = cmd + " clone --noupdate #{remote_url} #{local_url}"
    return exec(command)
  end

end
