require 'json'

class BitbucketAdapter

  def initialize(json)
    @payload = JSON.parse(json)['repository']

    case @payload['scm'].downcase
    when 'git'
      @scm = BitbucketGit
      git_cmd = Redmine::Configuration['scm_git_command']
      @cmd = git_cmd && !git_cmd.empty? ? git_cmd : 'git'
    when 'hg'
      @scm = BitbucketHg
      hg_cmd = Redmine::Configuration['scm_mercurial_command']
      @cmd = hg_cmd && !hg_cmd.empty? ? hg_cmd : 'hg'
    else
      raise TypeError, "Repository type (#{@payload['scm']}) not supported"
    end
  end

  def identifier
    "#{@payload['owner']}_#{@payload['slug']}"
  end

  def update_repository(repository)
    raise TypeError, "Invalid repository #{repository.identifier}" unless repository.is_a?(@scm.scm_class)
    @scm.update_repository(repository.url, @cmd)
  end

  def create_repository(project)
    path = "#{@payload['owner']}/#{@payload['slug']}"

    local_root_path = Setting.plugin_redmine_bitbucket[:local_path]
    local_url = "#{local_root_path}/#{project.identifier}/#{path}"

    FileUtils.mkdir_p(local_url) unless File.exists?(local_url)

    if @scm.clone_repository(path, local_url, @cmd)
      repository = @scm.scm_class.new
      repository.identifier = identifier
      repository.url = local_url
      repository.is_default = project.repository.nil?
      repository.project = project
      repository.save
      return repository
    end
  end

end
