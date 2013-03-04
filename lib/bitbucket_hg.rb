class BitbucketHg < SystemCommand

  HG_BIN = Redmine::Configuration['scm_mercurial_command'] || "hg"

  def self.scm_class
    Repository::Mercurial
  end

  # Fetches updates from the remote repository
  def self.update_repository(local_url)
    command = HG_BIN + " --repository '#{local_url}' pull"
    exec(command)
  end

  # Clone repository from Bitbucket
  def self.clone_repository(path, local_url)
    remote_url = "ssh://hg@bitbucket.org/#{path}"
    command = HG_BIN + " clone --noupdate #{remote_url} #{local_url}"
    return exec(command)
  end

end
