#
# Cookbook Name:: rvm
# Recipe:: install

ruby_version = [].tap do |v|
  v << node[:rvm][:ruby][:implementation] if node[:rvm][:ruby][:implementation]
  v << node[:rvm][:ruby][:version] if node[:rvm][:ruby][:version]
  v << node[:rvm][:ruby][:patch_level] if node[:rvm][:ruby][:patch_level]
end * '-'

include_recipe "rvm::default"

bash "installing #{ruby_version}" do
  user "root"
  code "/usr/local/bin/rvm install #{ruby_version}"
  not_if "rvm list | grep #{ruby_version}"
end

bash "make #{ruby_version} the default ruby" do
  user "root"
  code "/usr/local/bin/rvm --default #{ruby_version}"
  not_if "rvm list | grep '=> #{ruby_version}'"
  only_if { node[:rvm][:ruby][:default] }
#  notifies :restart, "service[chef-client]"
end

gem_package "chef" do
  gem_binary "/usr/local/bin/rvm-gem.sh"
  only_if "test -e /usr/local/bin/rvm-gem.sh"
  # re-install the chef gem into rvm to enable subsequent chef-client run
end

# make sure Vagrant uses the newly-installed chef-solo
template "/usr/local/bin/chef-solo" do
  source "chef-solo.erb"
  owner "root"
  group "root"
  mode 0755
  variables( :chef_solo => "#{`rvm gemdir`.chomp}/bin/chef-solo" )
end

# Needed so that chef doesn't freak out if the chef-client service
# isn't present.
#service "chef-client"
