# Define: mediawiki::extension
#
# This defined type allows management of extensions
#
# === Parameters
#
# [*instance*]      - instance getting the extension
# [*localpath*]     - local path where we'll find it
#
# === Examples
#
# class { 'mediawiki':
#   server_name      => 'www.example.com',
#   admin_email      => 'admin@puppetlabs.com',
#   db_root_password => 'really_really_long_password',
#   max_memory       => '1024'
# }
#
# mediawiki::instance { 'my_wiki1':
#   db_name     => 'wiki1_user',
#   db_password => 'really_long_password',
# }
#
## === Authors
#
# Jeff Vier <jeff@jeffvier.com>
#
# === Copyright
#
# Copyright 2015 Jeff Vier
#
define mediawiki::extension (
  $instance,
  $localpath,
  ) {

  include mediawiki::params
  Mediawiki::Instance[$instance] -> Mediawiki::Extension[$name]

  $ext_dir = "${mediawiki::params::conf_dir}/${instance}/extensions"

  file {
    "${ext_dir}/${name}":
      source  => "${localpath}/${name}",
      recurse => remote,
      force => true,
      require => Mediawiki::Instance[$instance];
  }

}