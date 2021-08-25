# document me
class puppet::common(
  $agent           = $::puppet::agent,
  $ca_server       = $::puppet::ca_server,
  $certname        = $::puppet::server_certname,
  $ensure          = $::puppet::ensure,
  $server          = $::puppet::server,
  $srv_domain      = $::puppet::srv_domain,
  $use_srv_records = $::puppet::use_srv_records,
  $puppet_config_file = $::puppet::puppet_config_file,
) {

  if $ca_server {
    augeas {'main_ca_server':
      context => '/files/etc/puppetlabs/puppet/puppet.conf',
      changes => [
        "set main/ca_server ${ca_server}",
      ],
    }
  }

  if $use_srv_records and $srv_domain {
    augeas {'main_srv_records':
      context => '/files/etc/puppetlabs/puppet/puppet.conf',
      changes => [
        'set main/use_srv_records true',
        "set main/srv_domain ${srv_domain}",
      ],
    }
  }

  if $certname {
    augeas {'main_certname':
      context => '/files/etc/puppetlabs/puppet/puppet.conf',
      changes => [
        "set main/certname ${certname}",
      ],
    }
  }

}
