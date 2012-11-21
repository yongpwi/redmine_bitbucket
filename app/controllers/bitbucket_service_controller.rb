require 'json'

class BitbucketServiceController < ApplicationController
  unloadable
  
  skip_before_filter :verify_authenticity_token, :check_if_login_required

  def index
    unless service_enabled? && valid_key?
      return render :nothing => true, :status => 404 
    end

    repository = find_repository

    if repository.nil? 
      logger.debug { "BitbucketPlugin: Invalid repository"}
      return render :nothing => true, :status => 500 
    end

    # Fetch the new changesets into Redmine
    repository.fetch_changesets

    render :nothing => true, :status => 200
  rescue ActiveRecord::RecordNotFound
    logger.debug { "BitbucketPlugin: RecordNotFound"}
    render :nothing => true, :status => 404
  end

  private

  def service_enabled?
    Setting.plugin_redmine_bitbucket[:service_enabled]
  end

  def valid_key?
    setting_key = Setting.plugin_redmine_bitbucket[:service_key]
    return true if setting_key.to_s == ''
    return params[:key] == setting_key
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
    project = find_project
    adapter = BitbucketAdapter.new(params[:payload])
    repository = project.repositories.find_by_identifier(adapter.identifier)
   
    if repository
      adapter.update_repository(repository)

    elsif Setting.plugin_redmine_bitbucket[:auto_create]
      # Clone the repository into Redmine
      repository = adapter.create_repository(project)

    else
      raise ActiveRecord::RecordNotFound
    end

    return repository
  end

end
