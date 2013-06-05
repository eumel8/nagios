class nagios::checks::uucp
{
  @@nagios_service{"check_uucp_${::fqdn}":
    use                 => 'cloud-service',
    check_command       => 'check_tcp!540',
    service_description => 'UUCP',
    host_name           => $::fqdn,
  }
}
