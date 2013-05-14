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

Define some default checks:

	class {'nagios::checks::system':}

Install NRPE and configure allowed hosts:

	class {'nagios::nrpe':
          nrpe_allowed_hosts  => '192.168.0.10',
          timeserver          => '192.168.0.15',
          nrpe_conf_overwrite => 1,
	}

Define service checks:

	class {'nagios::checks::http':}
	class {'nagios::checks::smtp':}
	class {'nagios::checks::chev':}


Testing
-------

Developed for Ubuntu, will be expand. 


Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b my_markup`)
3. Commit your changes (`git commit -am "Added Snarkdown"`)
4. Push to the branch (`git push origin my_markup`)
5. Open a [Pull Request][1]
6. Enjoy a refreshing Diet Coke and wait


