# == Class: nagios::nrpe
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

class nagios::nrpe (
  $nrpe_allowed_hosts  = '127.0.0.1',
  $timeserver          = '127.0.0.1',
  $nrpe_conf_overwrite = 0
  )
  {
case $operatingsystem {

    'OpenSuSE': {
      package { 'nagios-nrpe':
        ensure   => present,
        alias    => 'nagios-nrpe-server',
      }
      service { 'nrpe':
        ensure   => running,
        enable   => true,
        require  => Package['nagios-nrpe-server'],
        alias    => 'nagios-nrpe-server',
      }
    }

    'Ubuntu': {
      package { 'nagios-nrpe-server':
        ensure   => present,
      }
      package { 'libnagios-plugin-perl':
        ensure   => present,
      }
      service { 'nagios-nrpe-server':
        ensure   => running,
        enable   => true,
        require  => Package['nagios-nrpe-server'],
      }
    }

    default: {
    warning('No supported operating system')
  }
}

  package { 'nagios-plugins':
      ensure   => present,
  }


  file { '/usr/lib/nagios/plugins':
      ensure   => directory,
      source   => 'puppet:///modules/nagios/plugins',
      recurse  => true,
      purge    => false,
      force    => true,
      require  => Package['nagios-plugins'],
  }

  file { '/usr/local/bin/collect_checks_pl':
      ensure    => file,
      mode      => '1755',
      content   => template('nagios/collect_checks_pl.erb'),
  }

  exec { 'create_ext_services':
      command => '/usr/local/bin/collect_checks_pl',
      creates => '/etc/nagios/nagios_ext_services.cfg',
      require => File['/usr/local/bin/collect_checks_pl'],
  }

  if ($nrpe_conf_overwrite == 1) {

    file { '/etc/nagios/nrpe.cfg':
      ensure    => file,
      content   => template('nagios/nrpe.erb'),
      require   => Package['nagios-nrpe-server'],
      notify    => Service['nagios-nrpe-server']
    }

  } else {

    file { '/etc/nagios/nrpe_cloud.cfg':
      ensure    => file,
      content   => template('nagios/nrpe.erb'),
      require   => Package['nagios-nrpe-server'],
      notify    => Service['nagios-nrpe-server']
    }


    exec { 'nrpe_add_include_dir':
      command   => 'echo "include=/etc/nagios/nrpe_cloud.cfg" >> /etc/nagios/nrpe.cfg',
      path      => '/bin:/usr/bin',
      unless    => 'grep -e "^include=/etc/nagios/nrpe_cloud.cfg" /etc/nagios/nrpe.cfg',
      require   => Package['nagios-nrpe-server'],
      notify    => Service['nagios-nrpe-server'],
    }
  }

    file { '/etc/nagios/ext':
      ensure  => directory,
    }

    @@file { "/etc/nagios/ext/$::fqdn.cfg":
      content => $::nagios_ext_services,
      tag     => 'nagios_ext_services',
    }
}
