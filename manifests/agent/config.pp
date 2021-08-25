# document me
class puppet::agent::config (
  $agent           = $::puppet::agent,
  $environment     = $::puppet::environment,
  $use_srv_records = $::puppet::use_srv_records,
  $puppetmaster    = $::puppet::puppetmaster,
  $certname        = $::puppet::certname,
  $puppet_config_file = $::puppet::puppet_config_file,
) {

  augeas { 'agent':
    context => '/files/etc/puppetlabs/puppet/puppet.conf',
    changes => [
      "set agent/environment ${environment}",
      "set agent/certname ${certname}",
    ],
  }

  if ! $use_srv_records {
    augeas { 'agent_server':
      context => '/files/etc/puppetlabs/puppet/puppet.conf',
      changes => [
        "set agent/server ${puppetmaster}",
      ],
    }
  }

  if $::osfamily == 'Debian' {
    if $agent {
      $start = 'yes'
    } else {
      $start = 'no'
    }

    file { '/etc/default/puppet':
      content => inline_template('START=<%= @start %>'),
    }
  }
}
