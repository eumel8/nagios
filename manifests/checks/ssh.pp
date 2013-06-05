class nagios::checks::ssh 
 {
   @@nagios_service{"check_ssh_${::fqdn}":
     use                 => 'cloud-service',
     check_command       => 'check_tcp!22',
     service_description => 'SSH',
     host_name           => $::fqdn,
   }
}
