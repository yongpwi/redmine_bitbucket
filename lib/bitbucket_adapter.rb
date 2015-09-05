class BitbucketAdapter

  def initialize(json, new_webhook)
    if new_webhook
      load_new_webhook_parameters(json)
    else
      load_old_service_parameters(json)
    end
  end

  def identifier
    "#{@owner}_#{@slug}"
  end

  def update_repository(repository)
    raise TypeError, "Invalid repository #{repository.identifier}" unless repository.is_a?(@scm.scm_class)
    @scm.update_repository(repository.url)
  end

  def create_repository(project)
    path = "#{@owner}/#{@slug}"

    local_root_path = Setting.plugin_redmine_bitbucket[:local_path]
    local_url = "#{local_root_path}/#{path}/#{project.identifier}/"

    FileUtils.mkdir_p(local_url) unless File.exists?(local_url)

    if @scm.clone_repository(path, local_url)
      repository = @scm.scm_class.new
      repository.identifier = identifier
      repository.url = local_url
      repository.is_default = project.repository.nil?
      repository.project = project
      repository.save
      return repository
    end
  end

  private
  
  def load_new_webhook_parameters(json)
    @owner = json['owner']['username']
    @slug = json['full_name'].split('/').last
	
    load_scm(json['scm'].downcase)
  end
  
  def load_old_service_parameters(json)
    @owner = json['owner']
    @slug = json['slug']
	
    load_scm(json['scm'].downcase)
  end
  
  def load_scm(scm)
    case scm
    when 'git'
      @scm = BitbucketGit
    when 'hg'
      @scm = BitbucketHg
    else
      raise TypeError, "Repository type (#{scm}) not supported"
    end
  end
  
end
