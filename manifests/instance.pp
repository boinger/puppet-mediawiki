# == Define: mediawiki::instance
#
# This defined type allows the user to create a mediawiki instance.
#
# === Parameters
#
# [*db_name*]        - name of the mediawiki instance mysql database
# [*db_user*]        - name of the mysql database user
# [*db_password*]    - password for the mysql database user
# [*ip*]             - ip address of the mediawiki web server
# [*port*]           - port on mediawiki web server
# [*server_aliases*] - an array of mediawiki web server aliases
# [*ensure*]         - the current status of the wiki instance
#                    - options: present, absent, deleted
#
# === Examples
#
# class { 'mediawiki':
#   admin_email      => 'admin@puppetlabs.com',
#   db_root_password => 'really_really_long_password',
#   max_memory       => '1024'
# }
#
# mediawiki::instance { 'my_wiki1':
#   db_password => 'really_long_password',
#   db_name     => 'wiki1',
#   db_user     => 'wiki1_user',
#   port        => '80',
#   ensure      => 'present'
# }
#
# === Authors
#
# Martin Dluhos <martin@gnu.org>
#
# === Copyright
#
# Copyright 2012 Martin Dluhos
#
define mediawiki::instance (
  $db_password,
  $db_name        = $name,
  $db_user        = "${name}_user",
  $ip             = '*',
  $port           = '80',
  $subdir_name    = $name,
  $server_aliases = '',
  $short_url      = false,
  $ssl            = false,
  $ensure         = 'present'
  ) {
  
  validate_re($ensure, '^(present|absent|deleted)$',
  "${ensure} is not supported for ensure.
  Allowed values are 'present', 'absent', and 'deleted'.")

  include mediawiki::params

  # MediaWiki needs to be installed before a particular instance is created
  Class['mediawiki'] -> Mediawiki::Instance[$name]

  # Make the configuration file more readable
  $admin_email             = $mediawiki::admin_email
  $db_root_password        = $mediawiki::db_root_password
  $server_name             = $mediawiki::server_name
  $doc_root                = $mediawiki::doc_root
  $mediawiki_install_path  = $mediawiki::mediawiki_install_path
  $mediawiki_conf_dir      = $mediawiki::params::conf_dir
  $mediawiki_install_files = $mediawiki::params::installation_files
  $apache_daemon           = $mediawiki::params::apache_daemon

  $wiki_doc_dir            = "${doc_root}/${subdir_name}"
  $wiki_conf_dir           = "${mediawiki_conf_dir}/${name}"
  $wiki_url_path           = "/${subdir_name}"

  if ($short_url) {
    $vh_rewrite = [
      {
        comment      => 'Shorten wiki URLs',
        rewrite_rule => ['/?wiki(/.*)?$ %{DOCUMENT_ROOT}/w/index.php [L]'],
      },
      {
        comment      => 'Redir / to Main_Page',
        rewrite_rule => ['^/*$ %{DOCUMENT_ROOT}/w/index.php [L]'],
      }
    ]
  } else {
    $vh_rewrite = undef
  }

  # Figure out how to improve db security (manually done by
  # mysql_secure_installation)
  case $ensure {
    'present', 'absent': {
      
      exec { "${name}-install_script":
        cwd         => "${mediawiki_install_path}/maintenance",
        command     => "/usr/bin/php install.php ${name} admin    \
                        --pass puppet                             \
                        --email ${admin_email}                    \
                        --server http://${server_name}            \
                        --scriptpath ${wiki_url_path}             \
                        --dbtype mysql                            \
                        --dbserver localhost                      \
                        --installdbuser root                      \
                        --installdbpass ${db_root_password}       \
                        --dbname ${db_name}                       \
                        --dbuser ${db_user}                       \
                        --dbpass ${db_password}                   \
                        --confpath ${wiki_conf_dir}               \
                        --lang en",
        creates     => "${wiki_conf_dir}/LocalSettings.php",
        subscribe   => File["${wiki_conf_dir}/images"],
      }

      # Ensure resource attributes common to all resources
      File {
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
        
      file {
        $wiki_conf_dir: ;

        "${wiki_conf_dir}/images":
          owner  => $::operatingsystem ? {
            /(?i)(redhat|centos)/ => 'apache',
            /(?i)(debian|ubuntu)/ => 'www-data',
            default               => undef,
          },
          group  => $::operatingsystem ? {
            /(?i)(redhat|centos)/ => 'apache',
            /(?i)(debian|ubuntu)/ => 'www-data',
            default               => undef,
          };

        $wiki_doc_dir:
          ensure  => $wiki_conf_dir,
          require => File[$wiki_conf_dir];
      }
      
      # Ensure that mediawiki configuration files are included in each instance.
      mediawiki::symlinks {
        $name:
          conf_dir      => $mediawiki_conf_dir,
          install_files => $mediawiki_install_files,
          target_dir    => $mediawiki_install_path,
      }
     
      # Each instance has a separate vhost configuration
      if ($ssl) {
        if ($port == '80') { $sslport = '443' } else { $sslport = $port }
        apache::vhost {
          $name:
            port          => $sslport,
            ssl           => true,
            docroot       => $doc_root,
            serveradmin   => $admin_email,
            servername    => $server_name,
            vhost_name    => $ip,
            serveraliases => $server_aliases,
            rewrites      => $vh_rewrite,
            ensure        => $ensure;
        }
      } else {
        apache::vhost {
          $name:
            port          => $port,
            docroot       => $doc_root,
            serveradmin   => $admin_email,
            servername    => $server_name,
            vhost_name    => $ip,
            serveraliases => $server_aliases,
            rewrites      => $vh_rewrite,
            ensure        => $ensure;
        }
      }
    }
    'deleted': {
      
      file {
        $wiki_conf_dir: # Remove the MediaWiki instance directory
          ensure  => absent,
          recurse => true,
          purge   => true,
          force   => true;

        $wiki_doc_dir: # Remove the symlink for the mediawiki instance directory
          ensure   => absent,
          recurse  => true;
      }

      mariadb::db { $db_name:
        user     => $db_user,
        password => $db_password,
        host     => 'localhost',
        grant    => ['all'],
        ensure   => 'absent',
      }

      apache::vhost { $name:
        port          => $port,
        docroot       => $doc_root,
        ensure        => 'absent',
      } 
    }
  }
}
