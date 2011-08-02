#
# Cookbook Name:: codefoundry
# Recipe:: default
#
# Copyright 2011, Ryan Blue
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# update to avoid package errors
include_recipe 'apt'

# ImageMagick is requried for paperclip
package 'imagemagick' do
  action :install
end

# start apache configuration
include_recipe 'apache2'
include_recipe 'apache2::mod_ssl'

# set up SVN hosting through apache and mod_dav_svn
include_recipe 'apache2::mod_dav_svn'
include_recipe 'subversion::client'

# storage for SVN projects
directory File.join( node[:codefoundry][:storage], 'svn' ) do
  recursive true
  owner node[:apache][:user]
  group node[:apache][:user]
  mode "0755"
end

# CF will proxy to an apache vhost for SVN
web_app "subversion" do
  template "svn-vhost.conf.erb"
  server_name "svn-host"
end

# storage for git projects
directory File.join( node[:codefoundry][:storage], 'git' ) do
  recursive true
  owner node[:apache][:user]
  group node[:apache][:user]
  mode "0755"
end

# add passenger/mod_rack and rails to run the CF application
include_recipe 'passenger_apache2::mod_rails'
include_recipe 'rails'

# set up the CodeFoundry application and vhost
app_path = File.join( node[:codefoundry][:apps_path], 'codefoundry', 'current' )
repo_path = File.join( node[:codefoundry][:apps_path], 'codefoundry', 'repo' )
db_link = File.join( node[:codefoundry][:apps_path], 'codefoundry', 'db' )

# get the CodeFoundry source code
include_recipe 'git'
git repo_path do
  repository node[:codefoundry][:git_url]
  reference node[:codefoundry][:git_ref]
  action :sync
end

# link 'current' to the repository
link app_path do
  to repo_path
end

# link 'db' to the actual db path.  this way, the application config can use
# paths like ../db/<env>.sqlite3, which work inside and outside the VM.
link db_link do
  to node[:codefoundry][:db_path]
end

# install gems required by CF
include_recipe 'bundler'
include_recipe 'bundler::install'

# create CodeFoundry's database.yml
template File.join( app_path, 'config', 'database.yml' ) do
  source "database.yml.erb"
  variables( node[:codefoundry] )
end

# create CodeFoundry's settings.yml
template File.join( app_path, 'config', 'settings.yml' ) do
  source "settings.yml.erb"
  variables( node[:codefoundry] )
end

# migrate the database
bash 'migrating to the lastest database version' do
  cwd app_path
  code "rake db:migrate"
  #user node[:apache][:user]
end

# set up self-signed cert and key (in templates/default)
cf_cert = File.join( node[:apache][:dir], 'ssl', 'codefoundry.crt' )
template cf_cert do
  source "codefoundry.crt"
end

cf_key = File.join( node[:apache][:dir], 'ssl', 'codefoundry.key' )
template cf_key do
  source "codefoundry.key"
end

# create the apache vhost for CF
web_app "codefoundry" do
  template "cf-vhost.conf.erb"
  server_name "codefoundry"
  docroot app_path
  cert_path cf_cert
  key_path cf_key
end

# (re)start the delayed_job service.  this should eventually be done through a
# real service resource, but those require a real service in /etc/init.d.  this
# is a temporary hack in the mean time; we use restart so that it is guaranteed
# to be freshly started after this run even if it was already running.
bash 'start delayed_job daemon' do
  code "#{File.join( app_path, 'script', 'delayed_job' )} restart"
  #user node[:apache][:user]
end
