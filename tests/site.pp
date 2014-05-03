node default {

  class {'nagios::nrpe':
    nrpe_allowed_hosts   => [$::ipaddress,'127.0.0.1'],
    timeserver           => $::ipaddress,
    nrpe_conf_overwrite  => 1,
    monitor_puppet_agent => 1,
  }

  class {'::nagios::server':
    engine             => 'icinga',
    notesurl           => 'http://pastebin.com/?host=$HOSTNAME$&srv=$SERVICEDESC$',
    http_users         => {
      admin => { 'password' => '$apr1$NRcUwBfc$txMxL8iSF4m2eB2l4IAeq.' }, # admin
      },
    twilio_account     => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    twilio_identifier  => 'abcdefghijklmnopqrstuvqxyz',
    twilio_from        => '%2B1123456790',
    twilio_to          => '%2B491721234567',
    notification       => ['root@localhost','nagios@localhost'],
    pnp4nagios         => 1,
    pnp4nagios_rrdbase => "/data/pnp4nagios/",  # needs the slash at the end
    nd                 => {
      "$::fqdn" => {
        'ip'       => $::ipaddress,
        'domain'   => $::domain,
        'services' => {
          'Ping' => { check => 'check_ping!200.0,60%!500.0,95%', notes => 'group_sms' },
          'Load' => { check => 'check_nrpe!check_load!15 10 5 30 25 20', notes => 'group_email,group_sms,group_voice'},
        },
      },
    },
  }
}
