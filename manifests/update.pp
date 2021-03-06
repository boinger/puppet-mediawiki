# == Define: mediawiki::update
#
# This defined type allows notfiy of update.php (which you sometimes need to do when you add an extension)
#
# === Authors
#
# Jeff Vier <jeff@jeffvier.com>
#
define mediawiki::update (
  $instance = $name,
  ) {
  
  include mediawiki::params

  exec {
    'update.php':
      cwd         => "${mediawiki::params::conf_dir}/${instance}",
      command     => "${mediawiki::params::conf_dir}/${instance}/maintenance/update.php --conf LocalSettings.php --quick",
      refreshonly => true,
      logoutput   => true,
  }

}
