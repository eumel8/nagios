# == Class: nagios::host
#
# Maintaining nagios and icinga environments
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Frank Kloeker <f.kloeker@t-online.de>
#
#

class nagios::host {

  @@nagios_host { $::fqdn:
    ensure  => present,
    alias   => $::hostname,
    address => $::ipaddress,
    use     => 'cloud-host',
  }

  nagios_host{ 'cloud-host':
    notifications_enabled           => '1',
    event_handler_enabled           => '1',
    flap_detection_enabled          => '1',
    failure_prediction_enabled      => '1',
    process_perf_data               => '1',
    retain_status_information       => '1',
    retain_nonstatus_information    => '1',
    check_command                   => 'check-host-alive',
    max_check_attempts              => '10',
    notification_interval           => '0',
    notification_period             => '24x7',
    notification_options            => 'd,u,r',
    contact_groups                  => 'admins2',
    register                        => '0',
  }

}
