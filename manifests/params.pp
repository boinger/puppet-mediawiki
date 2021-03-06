# === Class: mediawiki::params
#
#  The mediawiki configuration settings idiosyncratic to different operating
#  systems.
#
# === Parameters
#
# None
#
# === Examples
#
# None
#
# === Authors
#
# Martin Dluhos <martin@gnu.org>
#
# === Copyright
#
# Copyright 2012 Martin Dluhos
#
class mediawiki::params {

  $tarball_url        = 'http://releases.wikimedia.org/mediawiki/1.28/mediawiki-1.28.0.tar.gz'
  $conf_dir           = '/etc/mediawiki'
  $apache_daemon      = '/usr/sbin/apache2'
  $installation_files = [
                        'api.php',
                        'api.php5',
                        'cache',
                        'composer.json',
                        'docs',
                        'extensions',
                        'img_auth.php',
                        'img_auth.php5',
                        'includes',
                        'index.php',
                        'index.php5',
                        'languages',
                        'load.php',
                        'load.php5',
                        'maintenance',
                        'mw-config',
                        'opensearch_desc.php',
                        'opensearch_desc.php5',
                        'profileinfo.php',
                        'profileinfo.php5',
                        'resources',
                        'serialized',
                        'skins',
                        'StartProfiler.sample',
                        'thumb_handler.php',
                        'thumb_handler.php5',
                        'thumb.php',
                        'thumb.php5',
                        'wiki.phtml',
                        ]

  case $::operatingsystem {
    redhat, centos:  {
      $web_dir  = '/var/www/html'
      $doc_root = "${web_dir}/wikis"
      #$packages = ['php-gd', 'php-mysql', 'wget'] ## php stuff clobbered by site/manifests/virtual.pp
      $packages = []
    }
    debian:     {
      $web_dir  = '/var/www'
      $doc_root = "${web_dir}/wikis"
      $packages = ['php5', 'php5-mysql', 'wget']
    }
    ubuntu:     {
      $web_dir  = '/var/www'
      $doc_root = "${web_dir}/wikis"
      $packages = ['php5', 'php5-mysql', 'wget']
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
