# == Class: nagios::nrpe
#
# Maintaining nagios and icinga environments
# Configure NRPE Servoce
#
# === Variables
#
# [*nrpe_allowed_hosts*]
# String or array of allowed ipaddresses to connect nrpe service
#
# [*timeserver*]
# Which timeserver should I use for compare ntp service
#
# [*nrpe_conf_overwrite*]
# 0 = create nrpe_cloud.cfg and include this and the end of nrpe.cfg
# 1 = write all automatic configured entries in nrpe.cfg
#
# [*monitor_puppet_agent*]
# 0 = do nothing
# 1 = setup nrep check + cron for un-root monitoring puppet agent
#
# === Authors
#
# Frank Kloeker <f.kloeker@t-online.de>
#
#

class nagios::nrpe (
  $nrpe_allowed_hosts   = '127.0.0.1',
  $timeserver           = '127.0.0.1',
  $nrpe_conf_overwrite  = 0,
  $monitor_puppet_agent = 0
  )
  {
case $::operatingsystem {

    'OpenSuSE': {
      $nrpe_package = $::operatingsystemrelease ? {
        /12.1/                => 'nagios-nrpe',
        /12.2|12.3|13.1|13.2/ => 'nrpe',
      }

      package { 'nrpe_package':
        ensure   => present,
        name     => $nrpe_package,
      }
      case $::operatingsystemrelease {
        /12.*/: {
          package { 'nagios-plugins':
              ensure   => present,
          }
          package {
          [ 'nagios-plugins-mem','nagios-plugins-disk','nagios-plugins-dns','nagios-plugins-http','nagios-plugins-load','nagios-plugins-mailq','nagios-plugins-mysql','nagios-plugins-ntp_peer','nagios-plugins-ntp_time','nagios-plugins-procs','nagios-plugins-tcp','nagios-plugins-time','nagios-plugins-users','nagios-plugins-smtp','nagios-plugins-swap','nagios-plugins-log' ]:
            ensure   => installed,
            require  => Package['nagios-plugins'],
          }
        }
        /13.*/: {
          package { 'monitoring-plugins':
              alias    => 'nagios-plugins',
              ensure   => present,
          }
          package {
          [ 'monitoring-plugins-mem','monitoring-plugins-disk','monitoring-plugins-dns','monitoring-plugins-http','monitoring-plugins-load','monitoring-plugins-mailq','monitoring-plugins-mysql','monitoring-plugins-ntp_peer','monitoring-plugins-ntp_time','monitoring-plugins-procs','monitoring-plugins-tcp','monitoring-plugins-time','monitoring-plugins-users','monitoring-plugins-smtp','monitoring-plugins-swap','monitoring-plugins-log' ]:
            ensure   => installed,
            require  => Package['monitoring-plugins'],
          }
#          file { '/etc/nagios':
#            ensure => 'directory',
#	  }
		}
		default: {
		  fail('No supported operating system')
		}
	      }

	      service { 'nrpe':
		ensure   => running,
		enable   => true,
		require  => Package['nrpe_package'],
		alias    => 'nagios-nrpe-server',
	      }
	    }

	    'SLES': {
	      $nrpe_package = 'nagios-nrpe'

	      package { 'nrpe_package':
		ensure   => present,
		name     => $nrpe_package,
	      }
	      package { 'nagios-plugins':
		  ensure   => present,
	      }
	      package {
	      [ 'nagios-plugins-mem','nagios-plugins-disk','nagios-plugins-dns','nagios-plugins-http','nagios-plugins-load','nagios-plugins-mailq','nagios-plugins-mysql','nagios-plugins-ntp_peer','nagios-plugins-ntp_time','nagios-plugins-procs','nagios-plugins-tcp','nagios-plugins-time','nagios-plugins-users','nagios-plugins-smtp','nagios-plugins-swap','nagios-plugins-log' ]:
		ensure   => installed,
		require  => Package['nagios-plugins'],
	      }

	      service { 'nrpe':
		ensure   => running,
		enable   => true,
		require  => Package['nrpe_package'],
		alias    => 'nagios-nrpe-server',
	      }
	    }

	    'Ubuntu': {
	      package { 'nrpe_package':
		ensure   => present,
		name     => 'nagios-nrpe-server'
	      }
	      package { 'libmonitoring-plugin-perl':
		ensure   => present,
	      }
	      package { 'logaricheck':
		ensure   => present,
	      }
	      package { 'nagios-plugins':
		  ensure   => present,
	      }
	      service { 'nagios-nrpe-server':
		ensure   => running,
		enable   => true,
		require  => Package['nrpe_package'],
	      }
	    }

	    default: {
	      fail('No supported operating system')
	  }
	}




	  file { '/usr/lib/nagios/plugins':
	      ensure   => directory,
	      source   => 'puppet:///modules/nagios/plugins',
	      recurse  => true,
	      purge    => false,
	      force    => true,
	      require  => Package['nagios-plugins'],
	  }

	  file { '/etc/nrpe.cfg':
	    ensure => 'link',
    target => '/etc/nagios/nrpe.cfg',
  }

  if ($monitor_puppet_agent == 1) {
    cron {'monitor-puppet-agent':
      ensure  => present,
      command => '/usr/lib/nagios/plugins/local/check_puppet-agent > /tmp/check_puppet_agent.log',
      user    => 'root',
      minute  => [0,5,10,15,20,25,30,35,40,45,50,55],
      require => File['/usr/lib/nagios/plugins'],
    }

    exec {'check_puppet-agent_extra_run':
      command => '/bin/echo "OK Init..." > /tmp/check_puppet_agent.log',
      path    => '/bin:/usr/bin:/usr/lib',
      creates => '/tmp/check_puppet_agent.log',
    }
  }

  if ($nrpe_conf_overwrite == 1) {

    file { '/etc/nagios/nrpe.cfg':
      ensure    => file,
      content   => template('nagios/nrpe.erb'),
      require   => Package['nrpe_package'],
      notify    => Service['nagios-nrpe-server']
    }

  } else {

    file { '/etc/nagios/nrpe_cloud.cfg':
      ensure    => file,
      content   => template('nagios/nrpe.erb'),
      require   => Package['nrpe_package'],
      notify    => Service['nagios-nrpe-server']
    }


    exec { 'nrpe_add_include_dir':
      command   => 'echo "include=/etc/nagios/nrpe_cloud.cfg" >> /etc/nagios/nrpe.cfg',
      path      => '/bin:/usr/bin',
      unless    => 'grep -e "^include=/etc/nagios/nrpe_cloud.cfg" /etc/nagios/nrpe.cfg',
      require   => Package['nrpe_package'],
      notify    => Service['nagios-nrpe-server'],
    }
  }
}
