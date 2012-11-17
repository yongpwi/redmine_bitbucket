require 'json'

class BitbucketServiceController < ApplicationController
  unloadable
  
  skip_before_filter :verify_authenticity_token, :check_if_login_required

  def index
    @project = find_project
    @payload = JSON.parse(params[:payload])['repository']

    repository = find_repository

    if repository.nil?
      # Clone the repository into Redmine
      repository = create_repository
    else
      # Fetch the changes from Bitbucket
      update_repository(repository)
    end

    # Fetch the new changesets into Redmine
    repository.fetch_changesets

    render :nothing => true, :status => 200
  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => 404
  end

  private

  def system(command)
    Kernel.system(command)
  end

  # Executes shell command. Returns true if the shell command exits with a success status code
  def exec(command)
    logger.debug { "BitbucketPlugin: Executing command: '#{command}'" }

    # Get a path to a temp file
    logfile = Tempfile.new('bitbucket_plugin_exec')
    logfile.close

    success = system("#{command} > #{logfile.path} 2>&1")
    output_from_command = File.readlines(logfile.path)
    if success
      logger.debug { "BitbucketPlugin: Command output: #{output_from_command.inspect}"}
    else
      logger.error { "BitbucketPlugin: Command '#{command}' didn't exit properly. Full output: #{output_from_command.inspect}"}
    end

    return success
  ensure
    logfile.unlink
  end

  def git_command(command, repository)
    "git --git-dir='#{repository.url}' #{command}"
  end

  # Fetches updates from the remote repository
  def update_repository(repository)
    command = git_command('fetch origin', repository)
    if exec(command)
      command = git_command("fetch origin '+refs/heads/*:refs/heads/*'", repository)
      exec(command)
    end
  end

  # Finds the Redmine project in the database based on the given project identifier
  def find_project
    identifier = params[:project_id]
    scope = Project.active.has_module(:repository)
    project = scope.find_by_identifier(identifier.downcase)
    raise ActiveRecord::RecordNotFound unless project
    return project
  end

  # Returns the Redmine Repository object we are trying to update
  def find_repository
    repository_id = @payload['slug']
    repository = @project.repositories.find_by_identifier(repository_id)

    if repository.nil?
      logger.error { 'BitbucketPlugin: cannot find repository' }
    else
      raise TypeError, "Repository for project '#{@project.to_s}' ('#{repository_id}') is not a Git repository" unless repository.is_a?(Repository::Git)
    end 

    return repository
  end

  def create_repository
    scm = @payload['scm']
    raise TypeError, "Is not a Git repository" if scm.downcase != 'git'

    remote_url = "git@bitbucket.org:#{@payload['owner']}/#{@payload['slug']}.git"

    local_root_path = Setting.plugin_redmine_bitbucket[:local_path]
    local_url = "#{local_root_path}/#{@project.identifier}_#{@payload['owner']}_#{@payload['slug']}.git"
   
    command = "git clone --mirror #{remote_url} #{local_url}"
    if exec(command)
      repository = Repository.factory('Git')
      repository.identifier = @payload['slug']
      repository.url = local_url
      repository.is_default = @project.repository.nil?
      repository.project = @project
      repository.save
      return repository
    end
  end

end
