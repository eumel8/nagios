class nagios::checks::chev
  {
    @@nagios_service { "check_chev_${::fqdn}":
      use                 => 'cloud-service',
      check_command       => 'check_nrpe_1arg!check_chev',
      service_description => 'Chev',
      host_name           => $::fqdn,
    }
  }
