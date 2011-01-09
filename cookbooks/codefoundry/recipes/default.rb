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

include_recipe 'apache2'

# set up SVN hosting through apache and mod_dav_svn
include_recipe 'apache2::mod_dav_svn'
include_recipe 'subversion::client'

# storage
directory "#{node[:codefoundry][:repo_dir]}/svn" do
  recursive true
  owner node[:apache][:user]
  group node[:apache][:user]
  mode "0755"
end

# the apache vhost
#web_app "subversion" do
#  template "svn-vhost.conf.erb"
#  server_name "svn-host"
#end

# set up git hosting storage
directory "#{node[:codefoundry][:repo_dir]}/git" do
  recursive true
  owner node[:apache][:user]
  group node[:apache][:user]
  mode "0755"
end

# set up the CodeFoundry application

# clone the repository
# update the repository
# check out the correct tag
# create db.yml
# create settings.yml

# create the apache vhost
#web_app "codefoundry" do
#  template "cf-vhost.conf.erb"
#  server_name "codefoundry"
#end

