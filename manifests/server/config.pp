# document me
class puppet::server::config (
  $autosign        = $::puppet::autosign,
  $ca_enabled      = $::puppet::server_ca_enabled,
  $config_dir      = $::puppet::params::server_config_dir,
  $dns_alt_names   = $::puppet::dns_alt_names,
  $fileserver      = $::puppet::fileserver_conf,
  $java_opts       = $::puppet::server_java_opts,
  $log_dir         = $::puppet::server_log_dir,
  $log_file        = $::puppet::server_log_file,
  $server          = $::puppet::server,
  $puppetdb        = $::puppet::puppetdb,
  $puppetdb_port   = $::puppet::puppetdb_port,
  $puppetdb_server = $::puppet::puppetdb_server,
  $reports         = $::puppet::server_reports,
  $max_active_instances = $::puppet::server_max_active_instances,
  $firewall        = $::puppet::firewall,
  $puppet_config_file = $::puppet::puppet_config_file,
) {

  $file_ensure = $server ? {
    true    => 'file',
    default => 'absent'
  }

  File {
    ensure => $file_ensure,
    owner  => 'puppet',
    group  => 'puppet',
  }

  if $server {
    file { $log_dir:
      ensure => 'directory',
    }

    # Template uses
    # - $ca_enabled
    # - $dns_alt_names
    # - $puppetdb
    # - $reports
    augeas {'master':
      context => '/files/etc/puppetlabs/puppet/puppet.conf/master',
      changes => [
        'set vardir /opt/puppetlabs/server/data/puppetserver',
        'set logdir /var/log/puppetlabs/puppetserver',
        'set rundir /var/run/puppetlabs/puppetserver',
        'set pidfile /var/run/puppetlabs/puppetserver/puppetserver.pid',
        'set codedir /etc/puppetlabs/code',
        'set always_cache_features true',
        "set ca ${ca_enabled}"
      ],
    }

    if $ca_enabled and $autosign {
      augeas {'master_autosign':
        context => '/files/etc/puppetlabs/puppet/puppet.conf/master',
        changes => [
          'set autosign true',
        ],
      }
    }

    if $reports and (count($reports) > 0) {
      $reports_list = join($reports, ',')
      augeas {'master_reports':
        context => '/files/etc/puppetlabs/puppet/puppet.conf/master',
        changes => [
          "set reports ${reports_list}",
        ],
      }
    }

    if $puppetdb {
      augeas {'master_storeconfigs':
        context => '/files/etc/puppetlabs/puppet/puppet.conf/master',
        changes => [
          'set storeconfigs true',
          'set storeconfigs_backend puppetdb',
        ],
      }
    }
  }

  # Template uses
  # - $java_opts
  file { "${config_dir}/puppetserver":
    content => template("${module_name}/server/puppetserver.sysconfig.erb"),
  }

  # Template uses
  # - $ca_enabled
  file { '/etc/puppetlabs/puppetserver/services.d/ca.cfg':
    content => template("${module_name}/server/ca.cfg.erb"),
  }

  # Template uses
  # - $server_log_dir
  # - $server_log_file

  file { '/etc/puppetlabs/puppetserver/logback.xml':
    content => template("${module_name}/server/logback.xml.erb"),
  }

  file { '/etc/puppetlabs/puppetserver/request-logging.xml':
    content => template("${module_name}/server/request-logging.xml.erb"),
  }

  file { '/etc/puppetlabs/puppetserver/conf.d/auth.conf':
    content => template("${module_name}/server/auth.conf.erb"),
  }

  file { '/etc/puppetlabs/puppetserver/conf.d/global.conf':
    content => template("${module_name}/server/global.conf.erb"),
  }

  file { '/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf':
    content => template("${module_name}/server/puppetserver.conf.erb"),
  }

  file { '/etc/puppetlabs/puppetserver/conf.d/web-routes.conf':
    content => template("${module_name}/server/web-routes.conf.erb"),
  }

  file { '/etc/puppetlabs/puppetserver/conf.d/webserver.conf':
    content => template("${module_name}/server/webserver.conf.erb"),
  }

  if ( $server and $fileserver ) {
    # Template uses
    # - $fileserver
    file { '/etc/puppetlabs/puppet/fileserver.conf':
      content => template('puppet/server/fileserver.conf.erb'),
    }
  }

  if ( $server and $puppetdb) {
    file { '/etc/puppetlabs/puppet/routes.yaml':
      source => 'puppet:///modules/puppet/routes.yaml',
    }

    # Template uses
    # - $puppetdb_port
    # - $puppetdb_server
    file { '/etc/puppetlabs/puppet/puppetdb.conf':
      content => template('puppet/server/puppetdb.conf.erb'),
    }
  }

  if $firewall {
    # Allow inbound connections
    firewall { '500 allow inbound connections to puppetserver':
      action => 'accept',
      state  => 'NEW',
      dport  => '8140',
    }
  }
}
