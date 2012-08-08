require 'spec_helper'

# A few useful variables: What if someone decides to change the variable values
# in params.pp?
# mediawiki_conf_dir     
# mediawiki_install_files
# instance_root_dir      
# apache_daemon           

describe 'mediawiki::instance', :type => :define do

  context 'using default parameters on Debian' do
    let(:pre_condition) do
      'class { "mediawiki": 
         server_name      => "www.example.com",
         admin_email      => "admin@puppetlabs.com",
         db_root_password => "really_really_long_password" }'
    end
    
    let(:facts) do
      {
        :osfamily => 'Debian',
        :operatingsystem => 'Debian'
      }
    end
    
    let(:params) do
      {
        :db_password => 'lengthy_password'
      }
    end

    let(:title) do
      'dummy_instance'
    end
    
    it 'should have enabled the instance' do
      should contain_class('mediawiki::params')
      
      should contain_file('/etc/mediawiki/dummy_instance').with( 
        'ensure'   => 'directory',
        'owner'    => 'root',
        'group'    => 'root',
        'mode'     => '0755',
      )
      
     should contain_file('/etc/mediawiki/dummy_instance/images').with(
        'ensure'   => 'directory',
        'owner'    => 'root',
        'group'    => 'www-data',
        'mode'     => '0755',
      )
      
      ['api.php', 'config', 'extensions','img_auth.php',
       'includes', 'index.php', 'load.php', 'languages',
       'maintenance', 'mw-config', 'opensearch_desc.php',
       'profileinfo.php', 'redirect.php', 'redirect.phtml',
       'resources', 'skins', 'thumb_handler.php',
       'thumb.php', 'wiki.phtml'].each do |f| 
      should contain_file(f).with(
        'ensure'  => 'link',
        'path'    => "/etc/mediawiki/dummy_instance/#{f}", 
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0755',
        'target'  => "/usr/share/mediawiki/#{f}",
       )
      end
      
      should contain_file('/var/www/wikis/dummy_instance').with(
        'ensure'   => 'link',
        'owner'    => 'root',
        'group'    => 'root',
      )

      should contain_apache__vhost('dummy_instance').with(
        'port'         => '80',
        'docroot'      => '/var/www/wikis',
        'serveradmin'  => 'admin@puppetlabs.com',
        'template'     => 'mediawiki/instance_vhost.erb',
        'ensure'       => 'present',
      )
    end
  end
  
  context 'using custom parameters on Debian' do
    let(:pre_condition) do
      'class { "mediawiki": 
         server_name      => "www.example.com",
         admin_email      => "admin@puppetlabs.com",
         db_root_password => "really_really_long_password" }'
    end
    
    let(:facts) do
      {
        :osfamily => 'Debian',
        :operatingsystem => 'Debian'
      }
    end
    
    let(:params) do
      {
        :db_password => 'super_long_password',
        :db_name     => 'dummy_db',
        :db_user     => 'dummy_user',
      }
    end
    
    let(:title) do
      "dummy_instance"
    end
    
    it 'should have disabled the instance' do
      params.merge!({'ensure' => 'absent'})
      should contain_class('mediawiki')
      should contain_class('mediawiki::params')
      
      should contain_file('/etc/mediawiki/dummy_instance').with( 
        'ensure'   => 'directory',
        'owner'    => 'root',
        'group'    => 'root',
        'mode'     => '0755',
      )
     
      should contain_file('/etc/mediawiki/dummy_instance/images').with(
        'ensure'   => 'directory',
        'owner'    => 'root',
        'group'    => 'www-data',
        'mode'     => '0755',
      )
      
      ['api.php', 'config', 'extensions','img_auth.php',
       'includes', 'index.php', 'load.php', 'languages',
       'maintenance', 'mw-config', 'opensearch_desc.php',
       'profileinfo.php', 'redirect.php', 'redirect.phtml',
       'resources', 'skins', 'thumb_handler.php',
       'thumb.php', 'wiki.phtml'].each do |f| 
      should contain_file(f).with(
        'ensure'  => 'link',
        'path'    => "/etc/mediawiki/dummy_instance/#{f}", 
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0755',
        'target'  => "/usr/share/mediawiki/#{f}",
      )
      end 
      
      should contain_file('/var/www/wikis/dummy_instance').with(
        'ensure'   => 'link',
        'owner'    => 'root',
        'group'    => 'root',
      )
      
      
      should contain_apache__vhost('dummy_instance').with(
        'port'         => '80',
        'docroot'      => '/var/www/wikis',
        'serveradmin'  => 'admin@puppetlabs.com',
        'template'     => 'mediawiki/instance_vhost.erb',
        'ensure'       => 'absent',
      ) 
    end
    
    it 'should have deleted the instance' do
      params.merge!({'ensure' => 'deleted'})
      should contain_class('mediawiki')
      should contain_class('mediawiki::params')
      
      should contain_mysql__db('dummy_db').with(
        'user'     => 'dummy_user',
        'password' => 'super_long_password',
        'host'     => 'localhost',
      ) 
      
      should contain_file('/etc/mediawiki/dummy_instance').with( 
        'ensure'   => 'absent',
      )
     
      
      should contain_file('/var/www/wikis/dummy_instance').with(
        'ensure'   => 'absent',
      )
      
      should contain_mysql__db('dummy_db').with(
        'user'     => 'dummy_user',
        'password' => 'super_long_password',
        'host'     => 'localhost',
        'grant'    => 'all',
        'ensure'   => 'absent',
      )  
      
      should contain_apache__vhost('dummy_instance').with(
        'port'         => '80',
        'docroot'      => '/var/www/wikis',
        'serveradmin'  => 'admin@puppetlabs.com',
        'template'     => 'mediawiki/instance_vhost.erb',
        'ensure'       => 'absent',
      ) 
    end
  end
    

  # Add additional contexts for different Ubuntu and CentOS
  context 'using default parameters on Ubuntu' do
    let(:pre_condition) do
      'class { "mediawiki": 
         server_name      => "www.example.com",
         admin_email      => "admin@puppetlabs.com",
         db_root_password => "really_really_long_password" }'
    end
    
    let(:facts) do
      {
        :osfamily => 'Debian',
        :operatingsystem => 'Ubuntu'
      }
    end
    
    let(:params) do
      {
        :db_password => 'lengthy_password'
      }
    end
  end
  
  context 'using default parameters on CentOS and RedHat' do
    let(:pre_condition) do
      'class { "mediawiki": 
         server_name      => "www.example.com",
         admin_email      => "admin@puppetlabs.com",
         db_root_password => "really_really_long_password" }'
    end
    
    let(:facts) do
      {
        :operatingsystem => 'RedHat'
      }
    end
    
    let(:params) do
      {
        :db_password => 'lengthy_password',
      }
    end
    
    let(:title) do
      "dummy_instance"
    end
  end
end
