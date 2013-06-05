class nagios::checks::http
 {
   @@nagios_service{"check_http_${::fqdn}":
     use                 => 'cloud-service',
     check_command       => 'check_http',
     service_description => 'HTTP',
     host_name           => $::fqdn,
   }
}
