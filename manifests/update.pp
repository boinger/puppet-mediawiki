# == Define: mediawiki::update
#
# This defined type runs update.php (which you sometimes need to do when you add an extension)
#
# === Authors
#
# Jeff Vier <jeff@jeffvier.com>
#
class mediawiki::update {
  
  exec {
    'update.php':
      cwd         => $mediawiki_install_path,
      command     => 'maintenance/update.php',
      refreshonly => true,
  }

}
