# document me
class puppet::server::install (
  $puppetdb         = $::puppet::puppetdb,
  $puppetdb_version = $::puppet::puppetdb_version,
  $server           = $::puppet::server,
  $server_version   = $::puppet::server_version,
  $puppetmaster     = $::puppet::puppetmaster,
) {

  $_server_version = $server ? {
    true    => $server_version,
    default => 'absent'
  }

  if $server {
    $_puppetdb_version = $puppetdb ? {
      true    => $puppetdb_version,
      default => 'absent'
    }
  } else {
    $_puppetdb_version = 'absent'
  }

  package { 'puppetserver':
    ensure => $_server_version,
  }

   file { '/usr/local/etc/puppetserver_cert_gen_control':
    ensure  => file,
    content => 'CA e CERT ja foram gerados',
    notify  => Exec['gera_ca'],
  }

  exec { 'gera_ca':
    command => 'puppet cert list -a',
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin:/opt/puppetlabs/puppet/bin',
    notify  => Exec['gera_puppetserver_certs'],
    refreshonly => true,
  }

  exec { 'gera_puppetserver_certs':
      command => "puppet cert generate ${puppetmaster} --dns_alt_names=puppet",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin:/opt/puppetlabs/puppet/bin',
    refreshonly => true,
  }

  package { 'puppetdb-termini':
    ensure => $_puppetdb_version,
  }

  # Set up environments
  file { '/etc/puppetlabs/code/environments':
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '2775',
  }

}
