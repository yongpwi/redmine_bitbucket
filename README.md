# Redmine Bitbucket plugin #

This plugin allows you to update your local repositories in Redmine when changes have been pushed to Bitbucket.

## Description ##

Redmine <http://redmine.org> has supported Git/Hg repositories for a long time, allowing you to browse your code and view your changesets directly in Redmine. For this purpose, Redmine relies on local clones of the Git/Hg repositories.

The Redmine Bitbucket plugin allows Bitbucket to notify your Redmine installation when changes have been pushed to a repository, triggering an update of your local repository and Redmine data only when it is actually necessary.

## Installation ##

1. Installing the plugin

    * Copy redmine_bitbucket plugin to {redmine_root}/plugins on your redmine path
    * Run 'bundle install RAILS_ENV=production'
    * Run 'rake redmine:plugins NAME=redmine_bitbucket RAILS_ENV=production'
    * Restart Redmine.
    * Configure Local repositories path (default is {redmine_root}/bitbucket_repos) at Administration > Plugins >Redmine Bitbucket plugin, and make sure the folder is writable by web server user.
    * Configure SSH key for the web server user if need to pull from private repositories. (https://confluence.atlassian.com/display/BITBUCKET/Using+the+SSH+protocol+with+bitbucket)
    * You may need to drop to shell and su to your web server user and type ssh git@bitbucket.org to prompt to accept host key before it works in the background.
    * (optional) Configure the secret key 

2. Connecting Bitbucket to Redmine
    * On bitbucket.org, go to the repository Admin interface (the sprocket icon).
    * Under "hooks" add a new hook of type "POST" using the format: "[redmine_installation_url]/hooks/bitbucket/:project_id(?key=[***])"  (for example "http://example.com/hooks/bitbucket/example_project?key=supersecret").
    * Note: since v1.0 of this plugin, the POST url has changed to hooks/bitbucket/:project_id, which is not backwards compatible.

That's it. Bitbucket will now send a HTTP POST to the Redmine Bitbucket plugin whenever changes are pushed to Bitbucket. A new local repository will be created with Bitbucket's repository name as the identifier on first request. Then pull changes to the local repository and updating the Redmine database with them. Auto cloning can be disable under plugin setting, which only updating will be performed. 


### Assumptions ###

* Redmine running on a *nix-like system.
* Git 1.6 or higher available on the commandline.


This plugin is inspired by Redmine Github Hook from Jakob Skjerning ( http://github.com/koppen/redmine_github_hook )
