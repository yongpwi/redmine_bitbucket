Redmine::Plugin.register :redmine_bitbucket do
  name 'Redmine Bitbucket plugin'
  author 'Steve Qian'
  description 'This plugin allows you to update your local repositories in Redmine when changes have been pushed to Bitbucket.'
  version '0.0.1'
  url 'https://bitbucket.org/steveqx/redmine_bitbucket'

  settings :default => {
    :local_path => 'bitbucket_repos',
  }, :partial => 'settings/redmine_bitbucket'

end
