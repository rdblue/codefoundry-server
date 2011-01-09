Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # base this configuration off of the standard 32-bit lucid vm
  config.vm.box = 'base'
  # where you can find this vm
  config.vm.box_url = 'http://files.vagrantup.com/lucid32.box'

  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.forward_port "http-svn", 80, 8080

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  config.vm.share_folder("repositories", "/var/codefoundry", "repositories")
  config.vm.share_folder("db", "/var/db", "db")
  config.vm.share_folder("app", "/var/www/vhosts/codefoundry", "app")

  # Enable provisioning with chef solo, specifying a cookbooks path (relative
  # to this Vagrantfile), and adding some recipes and/or roles.
  #
  config.vm.provisioner = :chef_solo
  project_root = File.dirname( __FILE__ )
  config.chef.cookbooks_path = File.join( project_root, 'cookbooks' )

  # chef recipies to use
  #config.chef.add_recipe 'apache2'
  #config.chef.add_recipe 'apache2::mod_dav_svn'
  config.chef.add_recipe 'codefoundry'

  # You may also specify custom JSON attributes:
  #config.chef.json = {
  #  }

end
