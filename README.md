Nagios/Icinga/Nrpe Modul for Puppet
===================================

This module provides distributed configuration from Nagios/Icinga. It can define
"central service" monitor like accessibility of a server and can also collect
"discovered" services. It's used exported resources in Puppet.

Usage
-----


Install server and setup http authentication user:

    class {'nagios::server':
      engine     => 'icinga',
      http_users => {
        admin => { 'password' => '$apr1$x6DQznUt$hh05hGiXnBzfi4m0iKlty1' },
        peter => { 'password' => '$apr1$Pm4kjpYB$8KGIuRB49Skdf/5/nWfUN1' },
      }
    }

Using Twilio for SMS and Voice notification:

    class {'nagios::server':
      engine             => 'nagios',
      twilio_account     => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',  # your twilio account number
      twilio_identifier  => 'abcdefghijklmnopqrstuvqxyz',  # your twilio secret identifier
      twilio_from        => '%2B1123456790',               # your urlenode twilio number, e.g. +1 123 456 7890
      twilio_to          => '%2B491721234567',             # your urlencode oncall number, e.g +49 172 123 4567
    }

You can register for Twilio services on https://www.twilio.com

This version doesn't use exported resources in puppet. So all hosts must configured in an array:

    nd => {
      nagios => {
        'ip'       => '192.168.0.100',
        'domain'   => 'beispiel.de',
        'services' => {
          'Ping' => { check => 'check_ping!200.0,60%!500.0,95%', notes => 'group_sms' }, 
          'Load' => { check => 'check_nrpe!check_load!15 10 5 30 25 20', notes => 'group_email,group_sms,group_voice'},
        },
      },
      ns => {
        'ip'       => '192.168.0.10',
        'domain'   => 'beispiel.de',
        'services' => {
          'Ping' => { check => 'check_ping!200.0,60%!500.0,95%'},
        },
      },
      gw => {
        'ip'       => '192.168.0.1',
        'domain'   => 'beispiel.de',
        'services' => {
          'Ping' => { check => 'check_ping!400.0,80%!500.0,95%'},
        },
      },

'notes' are optional for services for additional notification SMS + Voice (delivered by Twilio).
Default notification for all services is email

Install NRPE and configure allowed hosts:

	class {'nagios::nrpe':
          nrpe_allowed_hosts  => '192.168.0.10',
          timeserver          => '192.168.0.15',
          nrpe_conf_overwrite => 1,
	}

Use distribted monitor system with NSCA:

    distribution       => {
      member             => 'client',        # possible values: client, master
      host               => '192.168.0.110', # master host ip address
      nsca_password      => '12345678',      # password for communication
    },


Testing
-------

Developed for Ubuntu and OpenSUSE, will be expand. 


Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b my_markup`)
3. Commit your changes (`git commit -am "Added Snarkdown"`)
4. Push to the branch (`git push origin my_markup`)
5. Open a [Pull Request][1]
6. Enjoy a refreshing Diet Coke and wait


