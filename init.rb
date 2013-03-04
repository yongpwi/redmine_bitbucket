Redmine::Plugin.register :redmine_bitbucket do
  name 'Redmine Bitbucket plugin'
  author 'Steve Qian'
  description 'This plugin allows you to update your local repositories in Redmine when changes have been pushed to Bitbucket.'
  version '0.1.0'
  url 'https://bitbucket.org/steveqx/redmine_bitbucket'

  settings :default => {
    :service_enabled => true,
    :auto_create => true,
    :local_path => 'bitbucket_repos',
    :key => '',
    :git_cmd_path => '',
    :hg_cmd_path => '',
  }, :partial => 'settings/redmine_bitbucket'

end
