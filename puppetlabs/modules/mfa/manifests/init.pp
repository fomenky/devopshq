# sv-mfa class definition
#
class mfa {
  if $kernel == "Linux" {
    
    # Global variables
    $asm_pwd = lookup('asm_password') # Sample usage of hiera 5
    # $asm_version = lookup('asm_version')
    # $svrepo = lookup('opsmgr_ip') 

    #classes to include
    #include sv_linux_base        # not needed since we moving to AWS now

    #Print classname to console
    $classname = 'mfa'
    notify { "$classname": }
    
    package { ['tomcat', 'tomcat-webapps', 'mysql-community-server']:
      ensure => installed
    }->
    service{ 'tomcat6':
      ensure => running,
      enable => true,
    }->    
    service{ 'iptables':
      ensure => 'stopped',
      enable => 'false',
    }-> 
    # Disable SELinux
    exec { 'disable SELinux':
      path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
      command => "setenforce 0",
    }->
    # Configure/Start MySQL
    file { '/data':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '755',
    }->
    file { '/data/mysql':
      ensure => directory,
      owner  => 'mysql',
      group  => 'mysql',
      mode   => '755',
    }->
    file { '/etc/my.cnf':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '644',
      source => "puppet:///modules/$classname/etc/my.cnf"
    }->
    service{ 'mysqld':
      ensure => running,      
      enable => true,
    }
    # aPersona Installation - TBM (To Be Modified)
    file { '/var/lib/asm_product':
      ensure => directory,
      recurse => 'remote'
      owner  => 'root',
      group  => 'root',
      mode   => '664',
      source => "puppet:///modules/$classname/var/lib/asm_product";
    }->    
    exec { 'copy asm_portal files':
      path => [ '/bin/', '/usr/bin/', '/sbin/', '/usr/sbin/' ],
      command => "cp -r asm_portal/ /var/lib/tomcat6/webapps/",
      cwd => '/var/lib/asm_product',
      creates => '/var/lib/tomcat6/webapps/asm_portal',      
    }->
    exec { 'copy asm files':
      path => [ '/bin/', '/usr/bin/', '/sbin/', '/usr/sbin/' ],
      command => "cp -r asm/ /var/lib/tomcat6/webapps/",
      cwd => '/var/lib/asm_product',
      creates => '/var/lib/tomcat6/webapps/asm',      
    }->
    file { '/var/lib/tomcat6/webapps/asm/WEB-INF/classes/apersona-db.properties':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '644',
      source => "puppet:///modules/$classname/var/lib/tomcat6/apersona-db.properties";
    }->
    file { '/var/lib/tomcat6/webapps/asm_portal/WEB-INF/classes/apersona-db.properties':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '644',
      source => "puppet:///modules/$classname/var/lib/tomcat6/apersona-db.properties";
    }->

    # Post-Installation NOTES
    file { '/root/README':
      ensure => file,
      source => "puppet:///modules/$classname/README";
    }->
    notify { '~ POST INSTALLATION MESSAGE ~':
      message => 'PLEASE SEE ~/README', 
    }

  } #END OF OS CHECK
} #END OF CLASSß
