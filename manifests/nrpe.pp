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
case $::operatingsystem {

    'OpenSuSE': {
      $nrpe_package = $::operatingsystemrelease ? {
        /12.1/           => 'nagios-nrpe',
        /12.2|12.3|13.1/ => 'nrpe',
      }

      package { "nrpe_package":
        ensure   => present,
        name     => $nrpe_package,
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

  package { 'nagios-plugins-mem':
      ensure   => present,
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

  file { '/etc/nrpe.cfg':
    ensure => 'link',
    target => '/etc/nagios/nrpe.cfg',
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
