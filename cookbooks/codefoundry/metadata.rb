maintainer        "Ryan Blue"
maintainer_email  "rdblue@gmail.com"
license           "Apache 2.0"
description       "Builds a CodeFoundry server"
version           "0.1.0"

recipe "codefoundry", "Installs CodeFoundry"

%w{ubuntu}.each do |os|
  supports os
end
