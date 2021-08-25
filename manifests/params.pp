# document me
class puppet::params {

  $agent_version = 'latest'
  $ca_server = undef
  $use_srv_records = false
  $srv_domain = undef
  $certname = $::networking['fqdn']
  $runmode = 'cron'
  $environment = 'production'
  $puppetmaster = "puppet.${::domain}"

  $dns_alt_names = undef
  $fileserver_conf = undef
  $puppetdb = false
  $puppetdb_port = 8081
  $puppetdb_server = undef
  $puppetdb_version = 'latest'
  $server_ca_enabled = true
  $server_certname = undef
  $server_java_opts = '-Xms2g -Xmx2g -XX:MaxPermSize=256m'
  $server_log_dir = '/var/log/puppetlabs/puppetserver'
  $server_log_file = 'puppetserver.log'
  $server_reports = undef
  $server_version = 'latest'
  $server_max_active_instances = 0
  $firewall = false

  case $::kernel {
    'windows': {
      $puppet_config_file = 'c:/ProgramData/PuppetLabs/puppet/etc/puppet.conf'
      $agent_package_name = 'Puppet Agent (64 bit)'
    }
    'Linux': {
      $puppet_config_file = '/etc/puppetlabs/puppet/puppet.conf'
      $agent_package_name = 'puppet-agent'
    }
    default: {
        fail("Architecture ${::architecture} on kernel ${::kernel} is not supported")
    }
  }

  case $::osfamily {
    'Debian': {
      $server_config_dir = '/etc/default'
    }
    'RedHat', 'Suse': {
      $server_config_dir = '/etc/sysconfig'
    }
    'windows': {
      $server_config_dir = undef
    }
    default: {
      fail("${::osfamily} is not supported.")
    }
  }
}
