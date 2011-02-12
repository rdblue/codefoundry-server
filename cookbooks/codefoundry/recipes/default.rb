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

# install ruby with rvm
include_recipe 'rvm'

# start apache configuration
include_recipe 'apache2'

# set up SVN hosting through apache and mod_dav_svn
include_recipe 'apache2::mod_dav_svn'
include_recipe 'subversion::client'

# storage for SVN projects
directory File.join( node[:codefoundry][:repo_dir], 'svn' ) do
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
directory File.join( node[:codefoundry][:repo_dir], 'git' ) do
  recursive true
  owner node[:apache][:user]
  group node[:apache][:user]
  mode "0755"
end

# add passenger/mod_rack and rails to run the CF application
include_recipe 'passenger_apache2::mod_rails'
include_recipe 'rails'

# set up the CodeFoundry application and vhost

# get the CodeFoundry source code
include_recipe 'git'
git node[:codefoundry][:app_dir] do
  repository node[:codefoundry][:app_git_url]
  reference node[:codefoundry][:app_git_tag]
  action :sync
end

# create CodeFoundry's database.yml
template File.join( node[:codefoundry][:app_dir], 'config', 'database.yml' ) do
  source "database.yml.erb"
  variables( node[:codefoundry] )
end

# create CodeFoundry's settings.yml
template File.join( node[:codefoundry][:app_dir], 'config', 'settings.yml' ) do
  source "settings.yml.erb"
  variables( node[:codefoundry] )
end

# create the apache vhost for CF
web_app "codefoundry" do
  template "cf-vhost.conf.erb"
  server_name "codefoundry"
  docroot node[:codefoundry][:app_dir]
end

