class nagios::checks::system {
  @@nagios_hostextinfo { $fqdn:
    ensure => present,
    icon_image_alt => $operatingsystem,
    icon_image => "base/$operatingsystem.png",
    statusmap_image => "base/$operatingsystem.gd2",
  }

  @@nagios_service { "check_ping_${::fqdn}":
    use                 => 'cloud-service',
    check_command       => 'check_ping!200.0,60%!500.0,95%',
    service_description => 'Ping',
    host_name           => $::fqdn,
  }

  @@nagios_service { "check_users_${::fqdn}":
    use                 => 'cloud-service',
    check_command       => 'check_nrpe!check_users!1 2',
    service_description => 'Users',
    host_name           => $::fqdn,
  }

  @@nagios_service { "check_load_${::fqdn}":
    use                 => 'cloud-service',
    check_command       => 'check_nrpe!check_load!15 10 5 30 25 20',
    service_description => 'Load',
    host_name           => $::fqdn,
  }

  @@nagios_service { "check_total_procs_${::fqdn}":
    use                 => 'cloud-service',
    check_command       => 'check_nrpe!check_total_procs!150 250',
    service_description => 'Procs',
    host_name           => $::fqdn,
  }

  @@nagios_service { "check_zombie_procs_${::fqdn}":
    use                 => 'cloud-service',
    check_command       => 'check_nrpe!check_zombie_procs!5 10',
    service_description => 'Zombies',
    host_name           => $::fqdn,
  }

  @@nagios_service { "check_disk_root_${::fqdn}":
    use                 => 'cloud-service',
    check_command       => 'check_nrpe!check_disk_root!20% 10% /',
    service_description => 'Disk /',
    host_name           => $::fqdn,
  }

  @@nagios_service { "check_memory_${::fqdn}":
    use                 => 'cloud-service',
    check_command       => 'check_nrpe!check_memory!20% 10%',
    service_description => 'Memory',
    host_name           => $::fqdn,
  }

  @@nagios_service{"check_conn_${::fqdn}":
    use                 => 'cloud-service',
    check_command       => 'check_nrpe!check_conn!200 1000',
    service_description => 'Connections',
    host_name           => $::fqdn,
  }

}
