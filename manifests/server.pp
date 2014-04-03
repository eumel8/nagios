# == Class: nagios::server
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

class nagios::server (

  $nd                = {},
  $nagios_server_ip  = '127.0.0.1',
  $engine            = undef,
  $distribution      = {},
  $http_users        = {},
  $twilio_account    = undef,
  $twilio_identifier = undef,
  $twilio_from       = undef,
  $twilio_to         = undef,

) {

file {
  [ '/tmp/nagios3',
    '/etc/nagios',
  ]:
    ensure  => directory,
    force   => true,
}

file {'/etc/nagios/scripts':
  ensure  => directory,
  require => File['/etc/nagios'],
}

case $engine {
    'nagios': {

      case $::operatingsystem {

        'OpenSuSE': {
          $target = 'nagios'

          package { 'nagios':
            ensure   => present,
          }
          package { 'nagios-plugins-nrpe':
            ensure   => present,
          }
          service { 'nagios':
            ensure   => running,
            enable   => true,
            require  => Package['nagios'],
          }
          file {'/etc/nagios/apache2.conf':
            ensure  => file,
            source  => 'puppet:///modules/nagios/nagios/apache2.conf.opensuse',
            force   => true,
            require => Package['nagios'];
          }
          case $distribution['member'] {
            'client': {
              package { 'nagios-nsca-client':
                ensure   => present,
              }
              file {"/etc/$target/send_nsca.cfg":
                ensure  => file,
                content => template('nagios/nagios/send_nsca_cfg.erb'),
                force   => true,
                require => Package['nagios-nsca-client'];
              }
              file {"/etc/$target/submit_service_check":
                ensure  => file,
                content => template('nagios/nagios/submit_service_check_opensuse.erb'),
                force   => true,
                require => Package['nagios-nsca-client'];
              }
            }
            'master': {
              package { 'nagios-nsca':
                ensure   => present,
              }
              file {"/etc/$target/nsca.cfg":
                ensure  => file,
                content => template('nagios/nagios/nsca_cfg.erb'),
                force   => true,
                require => Package['nagios-nsca'];
              }
              file {'/etc/xinetd.d/nsca':
                ensure  => file,
                source  => 'puppet:///modules/nagios/nagios/nsca.opensuse',
                force   => true,
                require => Package['nagios-nsca'];
              }
            }
            default: {
            }
          }


        }

        'Ubuntu': {
          $target = 'nagios3'

          package { 'nagios3':
            ensure   => present,
            alias    => 'nagios',
          }
          package { 'nagios-nrpe-plugin':
            ensure   => present,
          }
          service { 'nagios3':
            ensure   => running,
            enable   => true,
            require  => Package['nagios3'],
            alias    => 'nagios',
          }
          file {'/etc/nagios/apache2.conf':
            ensure  => file,
            source  => 'puppet:///modules/nagios/nagios/apache2.conf.ubuntu',
            force   => true,
            require => Package['nagios'];
          }
          exec { 'run_nagiosfile1_purger':
            command => '/etc/init.d/nagios3 stop;/usr/sbin/dpkg-statoverride --update --add nagios www-data 2710 /var/lib/nagios3/rw; /etc/init.d/nagios3 start',
            onlyif  => '/usr/bin/stat /var/lib/nagios3/rw | grep -c drwx------',
          }
          exec { 'run_nagiosfile2_purger':
            command => '/etc/init.d/nagios3 stop;/usr/sbin/dpkg-statoverride --update --add nagios nagios 751 /var/lib/nagios3; /etc/init.d/nagios3 start',
            onlyif  => '/usr/bin/stat /var/lib/nagios3 | grep -c drwxr-x---',
          }
          case $distribution['member'] {
            'client': {
              package { 'nsca-client':
                ensure   => present,
              }
              file {"/etc/$target/send_nsca.cfg":
                ensure  => file,
                content => template('nagios/nagios/send_nsca_cfg.erb'),
                force   => true,
                require => Package['nsca-client'];
              }
              file {"/etc/nagios/submit_service_check":
                ensure  => file,
                mode    => '0755',
                content => template('nagios/nagios/submit_service_check_ubuntu.erb'),
                force   => true,
                require => Package['nsca-client'];
              }
            }
            'master': {
              package { 'nsca':
                ensure   => present,
              }
              file {"/etc/$target/nsca.cfg":
                ensure  => file,
                content => template('nagios/nagios/nsca_cfg.erb'),
                force   => true,
                require => Package['nsca'];
              }
              file {'/etc/xinetd.d/nsca':
                ensure  => file,
                source  => 'puppet:///modules/nagios/nagios/nsca.ubuntu',
                force   => true,
                require => Package['nsca'];
              }
            }
            default: {
            }
          }

        }

        default: {
          error('No supported operating system')
        }
      }

      file {
        "/usr/share/nagios":
          ensure  => directory;

        "/var/cache/$target/":
          ensure  => directory,
          require => Package[nagios],
#          owner   => nagios,
#          group   => nagios,
          mode    => '0777';

        "/var/lib/$target/rw":
          ensure  => directory,
          require => Package[nagios],
          owner   => nagios,
          group   => nagios,
          mode    => '0777';

        "/var/lib/$target":
          ensure  => directory,
          require => Package[nagios],
          owner   => nagios,
          group   => nagios,
          mode    => '0750';

        "/var/lib/$target/spool":
          ensure  => directory,
          require => Package[nagios],
          owner   => nagios,
          group   => nagios,
          mode    => '0750';

        "/var/lib/$target/spool/checkresults":
          ensure  => directory,
          require => File["/var/lib/$target/spool"],
          owner   => nagios,
          group   => nagios,
          mode    => '0750';

#        '/usr/share/nagios/htdocs':
#          ensure  => directory,
#          source  => 'puppet:///modules/nagios/htdocs/nagios/',
#          owner   => root,
#          group   => root,
#          mode    => '0644',
#          recurse => true,
#          force   => true,
#          require => File['/usr/share/nagios'];

        "/etc/$target/nagios.cfg":
          ensure  => file,
          content => template('nagios/nagios/nagios_cfg.erb'),
          force   => true,
          require => Package['nagios'],
          notify  => Service['nagios'];

        "/etc/$target/resource.cfg":
          ensure  => file,
          source  => 'puppet:///modules/nagios/nagios/resource.cfg',
          force   => true,
          require => Package['nagios'];
#          notify  => Service['nagios'];

        "/etc/$target/cgi.cfg":
          ensure  => file,
          content => template('nagios/nagios/cgi_cfg.erb'),
          force   => true,
          require => Package['nagios'];

        '/etc/nagios/htpasswd.users':
          ensure  => present,
          content => template('nagios/http_users.erb'),
          force   => true,
          require => Package['nagios'];

        '/etc/nagios/scripts/twilio_sms.sh':
          ensure  => present,
          content => template('nagios/twilio_sms_sh.erb'),
          mode    => '0755',
          force   => true;

        '/etc/nagios/scripts/twilio_voice.sh':
          ensure  => present,
          content => template('nagios/twilio_voice_sh.erb'),
          mode    => '0755',
          force   => true;

        '/etc/apache2/conf.d/nagios.conf':
          ensure  => 'link',
          target  => '/etc/nagios/apache2.conf',
      }

      case $distribution['member'] {
        'client': {
          package { 'nagios-nsca-client':
            ensure   => present,
          }
          file {"/etc/$target/send_nsca.cfg":
            ensure  => file,
            content => template('nagios/nagios/send_nsca_cfg.erb'),
            force   => true,
            require => Package['nagios-nsca-client'];
          }
          file {"/etc/$target/submit_service_check":
            ensure  => file,
            content => template('nagios/nagios/submit_service_check_opensuse.erb'),
            force   => true,
            require => Package['nagios-nsca-client'];
          }
        }
        'master': {
          package { 'nagios-nsca':
            ensure   => present,
          }
          file {"/etc/$target/nsca.cfg":
            ensure  => file,
            content => template('nagios/nagios/nsca_cfg.erb'),
            force   => true,
            require => Package['nagios-nsca'];
          }
          file {'/etc/xinetd.d/nsca':
            ensure  => file,
            source  => 'puppet:///modules/nagios/nagios/nsca.opensuse',
            force   => true,
            require => Package['nagios-nsca'];
          }
        }
        default: {
        }
      }
  }

  'icinga': {

    case $::operatingsystem {

      'OpenSuSE': {
        $target = 'nagios'
    
        package { 'icinga':
          ensure  => installed,
          alias   => 'nagios',
        }
        package {
        [ 'icinga-doc', 'icinga-www' ]:
          ensure  => installed,
        }
        package { 'nagios-plugins-nrpe':
          ensure   => present,
        }
        file {'/etc/icinga/apache2.conf':
          ensure  => file,
          source  => 'puppet:///modules/nagios/icinga/apache2_opensuse.conf',
          force   => true,
          require => Package['icinga'],
          notify  => Service['icinga'];
        }
        case $distribution['member'] {
          'client': {
            package { 'nagios-nsca-client':
              ensure   => present,
            }
            file {"/etc/$target/send_nsca.cfg":
              ensure  => file,
              content => template('nagios/nagios/send_nsca_cfg.erb'),
              force   => true,
              require => Package['nagios-nsca-client'];
            }
            file {"/etc/$target/submit_service_check":
              ensure  => file,
              content => template('nagios/nagios/submit_service_check_opensuse.erb'),
              force   => true,
              require => Package['nagios-nsca-client'];
            }
          }
          'master': {
            package { 'nagios-nsca':
              ensure   => present,
            }
            file {"/etc/$target/nsca.cfg":
              ensure  => file,
              content => template('nagios/nagios/nsca_cfg.erb'),
              force   => true,
              require => Package['nagios-nsca'];
            }
            file {'/etc/xinetd.d/nsca':
              ensure  => file,
              source  => 'puppet:///modules/nagios/nagios/nsca.opensuse',
              force   => true,
              require => Package['nagios-nsca'];
            }
          }
          default: {
            }
          }

      }

      'Ubuntu': {
        $target = 'nagios3'

        file {'/etc/nagios3':
          ensure  => directory,
          force   => true,
        }
        package { 'icinga':
          ensure  => installed,
          alias   => 'nagios',
        }
        package {
        [ 'icinga-core', 'icinga-cgi', 'icinga-doc' ]:
          ensure  => installed,
        }
        package { 'nagios-nrpe-plugin':
          ensure   => present,
        }
        file {'/etc/icinga/apache2.conf':
          ensure  => file,
          source  => 'puppet:///modules/nagios/icinga/apache2_ubuntu.conf',
          force   => true,
          require => Package['icinga'],
          notify  => Service['icinga'];
        }
        exec { 'run_icingafile1_purger':
          command => '/etc/init.d/icinga stop;/usr/sbin/dpkg-statoverride --update --add nagios www-data 2710 /var/lib/icinga/rw; /etc/init.d/icinga start',
          onlyif  => '/usr/bin/stat /var/lib/icinga/rw | grep -c drwx------',
        }
#        exec { 'run_icingafile2_purger':
#          command => '/etc/init.d/icinga stop;/usr/sbin/dpkg-statoverride --update --add nagios nagios 751 /var/lib/icinga; /etc/init.d/icinga start',
#          onlyif  => '/usr/bin/stat /var/lib/icinga | grep -c drwxr-x---',
#        }
        case $distribution['member'] {
          'client': {
            package { 'nsca-client':
              ensure   => present,
            }
            file {"/etc/$target/send_nsca.cfg":
              ensure  => file,
              content => template('nagios/nagios/send_nsca_cfg.erb'),
              force   => true,
              require => Package['nsca-client'];
            }
            file {"/etc/nagios/submit_service_check":
              ensure  => file,
              mode    => '0755',
              content => template('nagios/nagios/submit_service_check_ubuntu.erb'),
              force   => true,
              require => Package['nsca-client'];
            }
          }
          'master': {
            package { 'nsca':
              ensure   => present,
            }
            file {"/etc/$target/nsca.cfg":
              ensure  => file,
              content => template('nagios/nagios/nsca_cfg.erb'),
              force   => true,
              require => Package['nsca'];
            }
            file {'/etc/xinetd.d/nsca':
              ensure  => file,
              source  => 'puppet:///modules/nagios/nagios/nsca.ubuntu',
              force   => true,
              require => Package['nsca'];
            }
          }
          default: {
          }
        }

      }

      default: {
        error('No supported operating system')
      }
    }


    service {
      'icinga':
        ensure     => running,
        alias      => 'nagios',
        hasstatus  => true,
        hasrestart => true,
        require    => Package[icinga],
    }

    file {
      '/usr/share/icinga':
        ensure  => directory;

      '/var/lib/icinga/':
        ensure  => directory,
        require => Package[icinga],
        owner   => nagios,
        group   => nagios,
        mode    => '0755';

      '/var/cache/icinga/':
        ensure  => directory,
        require => Package[icinga],
        owner   => nagios,
        group   => nagios,
        mode    => '0777';

      '/var/lib/icinga/spool':
        ensure  => directory,
        require => Package[icinga],
        owner   => nagios,
        group   => nagios,
        mode    => '0750';

      '/var/lib/icinga/rw':
        ensure  => directory,
        require => Package[icinga],
        owner   => nagios,
        group   => nagios,
        mode    => '0777';

      '/var/lib/icinga/spool/checkresults':
        ensure  => directory,
        require => File['/var/lib/icinga/spool'],
        owner   => nagios,
        group   => nagios,
        mode    => '0750';

#      '/usr/share/icinga/htdocs':
#        ensure  => directory,
#        source  => 'puppet:///modules/nagios/htdocs/icinga/',
#        owner   => root,
#        group   => root,
#        mode    => '0644',
#        recurse => true,
#        force   => true,
#        require => File['/usr/share/icinga'];

      '/etc/icinga/':
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0644',
        recurse => true,
        force   => true,
        notify  => Service['icinga'];

      '/etc/icinga/icinga.cfg':
        ensure  => file,
        content => template('nagios/icinga/icinga_cfg.erb'),
        owner   => root,
        group   => root,
        mode    => '0644',
        force   => true,
        require => Package['icinga'],
        notify  => Service['icinga'];

      '/etc/icinga/resource.cfg':
        ensure  => file,
        source  => 'puppet:///modules/nagios/icinga/resource.cfg',
        force   => true,
        require => Package['icinga'],
        notify  => Service['icinga'];

      '/etc/icinga/cgi.cfg':
        ensure  => file,
        content => template('nagios/icinga/cgi_cfg.erb'),
        force   => true,
        require => Package['icinga'],
        notify  => Service['icinga'];

      '/etc/icinga/htpasswd.users':
        ensure  => present,
        content => template('nagios/http_users.erb'),
        force   => true,
        require => Package['icinga'];

      '/etc/nagios/scripts/twilio_sms.sh':
        ensure  => present,
        content => template('nagios/twilio_sms_sh.erb'),
        mode    => '0755',
        force   => true;

      '/etc/nagios/scripts/twilio_voice.sh':
        ensure  => present,
        content => template('nagios/twilio_voice_sh.erb'),
        mode    => '0755',
        force   => true;


      '/etc/apache2/conf.d/icinga.conf':
        ensure  => 'link',
        target  => '/etc/icinga/apache2.conf';
      }

  }
  default: {
    warning('You have to define an engine')
  }
}

  file { "/etc/$target/nagios_host.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_host.erb'),
    force   => true,
    notify  => Service['nagios']
  }

  file { "/etc/$target/nagios_hostgroups.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_hostgroups.erb'),
    force   => true,
    notify  => Service['nagios']
  }

  file { "/etc/$target/nagios_service.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_service.erb'),
    force   => true,
    notify  => Service['nagios']
  }

  file { "/etc/$target/nagios_servicegroups.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_servicegroups.erb'),
    force   => true,
    notify  => Service['nagios']
  }

  file { "/etc/$target/nagios_contactgroup.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_contactgroup.erb'),
    force   => true,
    notify  => Service['nagios']
  }

  file { "/etc/$target/nagios_contact.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_contact.erb'),
    force   => true,
    notify  => Service['nagios']
  }

  file { "/etc/$target/nagios_timeperiod.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_timeperiod.erb'),
    force   => true,
    notify  => Service['nagios']
  }

#  file { "/etc/$target/nagios_hostextinfo.cfg":
#    ensure  => file,
#    content => template('nagios/nagios/nagios_hostextinfo.erb'),
#    force   => true,
#    notify  => Service['nagios']
#  }

  file { "/etc/$target/nagios_command.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_command.erb'),
    force   => true,
    notify  => Service['nagios']
  }
}
