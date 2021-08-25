class puppet::agent::install (
  Boolean $agent         = $::puppet::agent,
  String  $agent_version = $::puppet::agent_version,
  String  $agent_package_name  = $::puppet::agent_package_name,
){

  # puppetserver depends on agent, don't remove it if agent is false
  if $agent {
    if $::kernel == 'Linux' {
      package { $agent_package_name:
        ensure  => $agent_version,
      }
    }
  }

}
