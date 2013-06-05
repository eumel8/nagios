class nagios::checks::smtp
  {
    @@nagios_service{"check_smtp_${::fqdn}":
      use                 => 'cloud-service',
      check_command       => 'check_smtp!25',
      service_description => 'SMTP',
      host_name           => $::fqdn,
    }
  }
