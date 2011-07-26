default[:passenger][:version] = "3.0.7"
set[:passenger][:root_path]   = "#{languages[:ruby][:gems_dir]}/gems/passenger-#{passenger[:version]}"
set[:passenger][:module_path] = "#{passenger[:root_path]}/ext/apache2/mod_passenger.so"
set[:rvm][:current] = `rvm current`.chomp!
