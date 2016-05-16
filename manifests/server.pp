# == Class: nagios::server
#
# Maintaining nagios and icinga environments
# Configure Nagios/Icinga server
#
# === Variables
# [*nd*]
# Hash of nodes to monitor
#    nd => {
#      '<host>.<domain>' => {
#        'ip'       => '<ipaddress>,
#        'domain'   => '<domain>',
#        'services' => {
#          '<service description>'       => { check => '<check_command>', notes=> '<notification_service>'},
#        }
#      }
#    }
#
# [*engine*]
# String of monitor service (nagios, icinga)
#
# [*pnp4nagios*]
# String of pnp4nagios service (1,0)
#
# [*pnp4nagios_rrdbase*]
# String of path for rrd file performed by  pnp4nagios
#
# [*icli*]
# String of install icinga command line tool icli (1,0)
#
# [*distribution*]
# Hash of distrubtion service (client, master)
#   [*member*]
#      client = Client, send monitor data
#      master = Master, receive monitor data
#   [*host*]
#      string = Master hostname
#   [*nsca_password*]
#      string = password for encrypted communiation
#
# [*http_users*]
# Hash of username/password combinations to use the web frontend
#
# [*httpd_user*]
# String of username which is running httpd service (default: wwwrun)
#
# [*twilio_account*]
# String of the account name for Twilio service (SMS/Voice notifications)
#
# [*twilio_identifier*]
# String of the account identifierle for Twilio service (SMS/Voice notifications)
#
# [*twilio_from*]
# String of url-encoded phone number in Twilio service (SMS/Voice notifications)
#
# [*twilio_to*]
# String of url-encoded phone number to send notifications with Twilio
#
# [*notifications*]
# String/Array of email addresses for Email notification
#
# [*notesurl*]
# String/Array of (external) service url for service descripzion (i.e. Wiki)
#
# === Authors
#
# Frank Kloeker <f.kloeker@t-online.de>
#
#

class nagios::server (
  $nd                 = {},
  $engine             = undef,
  $pnp4nagios         = undef,
  $pnp4nagios_rrdbase = '/var/lib/pnp4nagios/perfdata/',
  $notesurl           = undef,
  $icli               = undef,
  $distribution       = {},
  $http_users         = {},
  $twilio_account     = undef,
  $twilio_identifier  = undef,
  $twilio_from        = undef,
  $twilio_to          = undef,
  $notification       = 'root@localhost',
  $httpd_user         = 'wwwrun'
) {

file {'/etc/nagios':
    ensure  => directory,
    force   => true,
}

file {'/etc/nagios/scripts':
  ensure  => directory,
  require => File['/etc/nagios'],
}

case $engine {
    'nagios': {

      if ($::operatingsystem in ['OpenSuSE', 'SLES']) {

          $target = 'nagios'

          package { 'nagios':
            ensure   => present,
          }
          package { 'nagios-www':
            ensure   => present,
          }
          package { 'monitoring-plugins-nrpe':
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
            require => Package['nagios'],
          }
          if ($pnp4nagios == 1) {
            file {'/etc/pnp4nagios/apache2.conf':
              ensure  => file,
              source  => 'puppet:///modules/nagios/nagios/pnp4nagios.conf.opensuse',
              force   => true,
              require => Package['pnp4nagios'],
            }
            file {'/etc/apache2/conf.d/pnp4nagios.conf':
              ensure  => 'link',
              target  => '/etc/pnp4nagios/apache2.conf',
            }
          }
          case $distribution['member'] {
            'client': {
              package {'nagios-nsca-client':
                ensure   => present,
              }
              file {"/etc/${target}/send_nsca.cfg":
                ensure  => file,
                content => template('nagios/nagios/send_nsca_cfg.erb'),
                force   => true,
                require => Package['nagios-nsca-client'];
              }
              file {"/etc/${target}/submit_service_check":
                ensure  => file,
                mode    => '0755',
                content => template('nagios/nagios/submit_service_check_opensuse.erb'),
                force   => true,
                require => Package['nagios-nsca-client'];
              }
              file {"/etc/${target}/submit_host_check":
                ensure  => file,
                mode    => '0755',
                content => template('nagios/nagios/submit_host_check_opensuse.erb'),
                force   => true,
                require => Package['nagios-nsca-client'];
              }
            }
            'master': {
              package { 'nagios-nsca':
                ensure  => present,
              }
              package { 'xinetd':
                ensure  => present,
              }
              service  { 'xinetd':
                ensure  => running,
                require => Package['xinetd'];
              }
              file {"/etc/${target}/nsca.cfg":
                ensure  => file,
                content => template('nagios/nagios/nsca_cfg.erb'),
                force   => true,
                require => Package['nagios-nsca'];
              }
              file {'/etc/xinetd.d/nsca':
                ensure  => file,
                source  => 'puppet:///modules/nagios/nagios/nsca.opensuse',
                force   => true,
                require => Package['nagios-nsca'],
                notify  => Service['xinetd'];
              }
            }
            default: {
            }
          }

      }
      elsif ($::operatingsystem == 'Ubuntu') {

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
            require => Package['nagios'],
          }
          if ($pnp4nagios == 1) {
            file {'/etc/pnp4nagios/apache.conf':
              ensure  => file,
              source  => 'puppet:///modules/nagios/nagios/pnp4nagios.conf.ubuntu',
              force   => true,
              require => Package['pnp4nagios'],
            }
            file {'/etc/apache2/conf.d/pnp4nagios.conf':
              ensure  => 'link',
              target  => '/etc/pnp4nagios/apache.conf',
            }
          }
          exec { 'run_nagiosfile1_purger':
            command => '/etc/init.d/nagios3 stop;/usr/sbin/dpkg-statoverride --update --add nagios www-data 2710 /var/lib/nagios3/rw; /etc/init.d/nagios3 start',
            onlyif  => '/usr/bin/stat /var/lib/nagios3/rw | grep -c drwx------',
          }
          exec { 'run_nagiosfile2_purger':
            command => '/etc/init.d/nagios3 stop;/usr/sbin/dpkg-statoverride --update --add nagios nagios 751 /var/lib/nagios3; /etc/init.d/nagios3 start',
            onlyif  => '/usr/bin/stat /var/lib/nagios3 | grep -c drwxr-x---',
          }
          exec { 'run_nagiosgroup_purger':
            path    => '/bin:/usr/bin:/usr/sbin',
            command => "usermod -a -G nagios ${httpd_user}",
            onlyif  => "id ${httpd_user}",
            unless  => "id ${httpd_user} | grep -c nagios",
            require => Package['nagios'];
          }
          case $distribution['member'] {
            'client': {
              package { 'nsca-client':
                ensure   => present,
              }
              file {"/etc/${target}/send_nsca.cfg":
                ensure  => file,
                content => template('nagios/nagios/send_nsca_cfg.erb'),
                force   => true,
                require => Package['nsca-client'];
              }
              file {'/etc/nagios/submit_service_check':
                ensure  => file,
                mode    => '0755',
                content => template('nagios/nagios/submit_service_check_ubuntu.erb'),
                force   => true,
                require => Package['nsca-client'];
              }
              file {'/etc/nagios/submit_host_check':
                ensure  => file,
                mode    => '0755',
                content => template('nagios/nagios/submit_host_check_ubuntu.erb'),
                force   => true,
                require => Package['nsca-client'];
              }
            }
            'master': {
              package { 'nsca':
                ensure  => present,
              }
              package { 'xinetd':
                ensure  => present,
              }
              service  { 'xinetd':
                ensure  => running,
                require => Package['xinetd'];
              }
              file {"/etc/${target}/nsca.cfg":
                ensure  => file,
                content => template('nagios/nagios/nsca_cfg.erb'),
                force   => true,
                require => Package['nsca'];
              }
              file {'/etc/xinetd.d/nsca':
                ensure  => file,
                source  => 'puppet:///modules/nagios/nagios/nsca.ubuntu',
                force   => true,
                require => Package['nsca'],
                notify  => Service['xinetd'];
              }
            }
            default: {
            }
          }
      }
      else {
        fail('No supported operating system')
      }

      file {
        '/usr/share/nagios':
          ensure  => directory;

        "/var/cache/${target}/":
          ensure  => directory,
          require => Package[nagios],
          mode    => '0777';

        "/var/lib/${target}/rw":
          ensure  => directory,
          require => Package[nagios],
          owner   => nagios,
          group   => nagios,
          mode    => '0777';

        "/var/lib/${target}":
          ensure  => directory,
          require => Package[nagios],
          owner   => nagios,
          group   => nagios,
          mode    => '0750';

        "/var/lib/${target}/spool":
          ensure  => directory,
          require => Package[nagios],
          owner   => nagios,
          group   => nagios,
          mode    => '0750';

        "/var/lib/${target}/spool/checkresults":
          ensure  => directory,
          require => File["/var/lib/${target}/spool"],
          owner   => nagios,
          group   => nagios,
          mode    => '0750',
          notify  => Service['nagios'];

        "/etc/${target}/nagios.cfg":
          ensure  => file,
          content => template('nagios/nagios/nagios_cfg.erb'),
          force   => true,
          require => Package['nagios'],
          notify  => Service['nagios'];

        "/etc/${target}/resource.cfg":
          ensure  => file,
          source  => 'puppet:///modules/nagios/nagios/resource.cfg',
          force   => true,
          require => Package['nagios'];

        "/etc/${target}/cgi.cfg":
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
          file {"/etc/${target}/send_nsca.cfg":
            ensure  => file,
            content => template('nagios/nagios/send_nsca_cfg.erb'),
            force   => true,
            require => Package['nagios-nsca-client'];
          }
          file {"/etc/${target}/submit_service_check":
            ensure  => file,
            mode    => '0755',
            content => template('nagios/nagios/submit_service_check_opensuse.erb'),
            force   => true,
            require => Package['nagios-nsca-client'];
          }
          file {"/etc/${target}/submit_host_check":
            ensure  => file,
            mode    => '0755',
            content => template('nagios/nagios/submit_host_check_opensuse.erb'),
            force   => true,
            require => Package['nagios-nsca-client'];
          }
        }
        'master': {
          package { 'nagios-nsca':
            ensure   => present,
          }
          file {"/etc/${target}/nsca.cfg":
            ensure  => file,
            content => template('nagios/nagios/nsca_cfg.erb'),
            force   => true,
            require => Package['nagios-nsca'];
          }
          file {'/etc/xinetd.d/nsca':
            ensure  => file,
            source  => 'puppet:///modules/nagios/nagios/nsca.opensuse',
            force   => true,
            require => Package['nagios-nsca'],
            notify  => Service['xinetd'];
          }
        }
        default: {
        }
      }
  }

  'icinga': {

      if ($::operatingsystem in ['OpenSuSE', 'SLES']) {

        $target = 'nagios'


        user { 'nagios':
          ensure => present,
        }

        group { "nagios":
          ensure => present,
        }

        package { 'icinga':
          ensure  => installed,
          alias   => 'nagios',
        }
        package {
        [ 'icinga-doc', 'icinga-www' ]:
          ensure  => installed,
        }
        package { 'monitoring-plugins-nrpe':
          ensure   => present,
        }
        file {'/etc/icinga/apache2.conf':
          ensure  => file,
          source  => 'puppet:///modules/nagios/icinga/apache2.conf.opensuse',
          force   => true,
          require => Package['icinga'],
        }
        if ($pnp4nagios == 1) {
          file {'/etc/pnp4nagios/apache2.conf':
            ensure  => file,
            source  => 'puppet:///modules/nagios/icinga/pnp4nagios.conf.opensuse',
            force   => true,
            require => Package['pnp4nagios'],
          }
          file {'/etc/apache2/conf.d/pnp4nagios.conf':
            ensure  => 'link',
            target  => '/etc/pnp4nagios/apache2.conf',
          }
        }
        case $distribution['member'] {
          'client': {
            package {'nagios-nsca-client':
              ensure   => present,
            }
            file {"/etc/${target}/send_nsca.cfg":
              ensure  => file,
              content => template('nagios/nagios/send_nsca_cfg.erb'),
              force   => true,
              require => Package['nagios-nsca-client'];
            }
            file {"/etc/${target}/submit_service_check":
              ensure  => file,
              mode    => '0755',
              content => template('nagios/nagios/submit_service_check_opensuse.erb'),
              force   => true,
              require => Package['nagios-nsca-client'];
            }
            file {"/etc/${target}/submit_host_check":
              ensure  => file,
              mode    => '0755',
              content => template('nagios/nagios/submit_host_check_opensuse.erb'),
              force   => true,
              require => Package['nagios-nsca-client'];
            }
          }
          'master': {
            package { 'nagios-nsca':
              ensure   => present,
            }
            file {"/etc/${target}/nsca.cfg":
              ensure  => file,
              content => template('nagios/nagios/nsca_cfg.erb'),
              force   => true,
              require => Package['nagios-nsca'];
            }
            file {'/etc/xinetd.d/nsca':
              ensure  => file,
              source  => 'puppet:///modules/nagios/nagios/nsca.opensuse',
              force   => true,
              require => Package['nagios-nsca'],
              notify  => Service['xinetd'];
            }
          }
          default: {
            }
          }

      }

      elsif ($::operatingsystem == 'Ubuntu') {

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
          source  => 'puppet:///modules/nagios/icinga/apache2.conf.ubuntu',
          force   => true,
          require => Package['icinga'],
        }
        if ($pnp4nagios == 1) {
          file {'/etc/pnp4nagios/apache.conf':
            ensure  => file,
            source  => 'puppet:///modules/nagios/icinga/pnp4nagios.conf.ubuntu',
            force   => true,
            require => Package['pnp4nagios'],
          }
          file {'/etc/apache2/conf.d/pnp4nagios.conf':
            ensure  => 'link',
            target  => '/etc/pnp4nagios/apache.conf',
          }
        }
        exec { 'run_icingafile1_purger':
          command => '/etc/init.d/icinga stop;/usr/sbin/dpkg-statoverride --update --add nagios www-data 2710 /var/lib/icinga/rw; /etc/init.d/icinga start',
          onlyif  => '/usr/bin/stat /var/lib/icinga/rw | grep -c drwx------',
        }
        exec { 'run_icingagroup_purger':
          path    => '/bin:/usr/bin:/usr/sbin',
          command => "usermod -a -G nagios ${httpd_user}",
          onlyif  => "id ${httpd_user}",
          unless  => "id ${httpd_user} | grep -c nagios",
          require => Package['icinga'],
        }

        case $distribution['member'] {
          'client': {
            package { 'nsca-client':
              ensure   => present,
            }
            file {"/etc/${target}/send_nsca.cfg":
              ensure  => file,
              content => template('nagios/nagios/send_nsca_cfg.erb'),
              force   => true,
              require => Package['nsca-client'];
            }
            file {'/etc/nagios/submit_service_check':
              ensure  => file,
              mode    => '0755',
              content => template('nagios/nagios/submit_service_check_ubuntu.erb'),
              force   => true,
              require => Package['nsca-client'];
            }
            file {'/etc/nagios/submit_host_check':
              ensure  => file,
              mode    => '0755',
              content => template('nagios/nagios/submit_host_check_ubuntu.erb'),
              force   => true,
              require => Package['nsca-client'];
            }
          }
          'master': {
            package { 'nsca':
              ensure   => present,
            }
            file {"/etc/${target}/nsca.cfg":
              ensure  => file,
              content => template('nagios/nagios/nsca_cfg.erb'),
              force   => true,
              require => Package['nsca'];
            }
            file {'/etc/xinetd.d/nsca':
              ensure  => file,
              source  => 'puppet:///modules/nagios/nagios/nsca.ubuntu',
              force   => true,
              require => Package['nsca'],
              notify  => Service['xinetd'];
            }
          }
          default: {
          }
        }
    }
    else {
      fail('No supported operating system')
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
        mode    => '0750',
        notify  => Service['icinga'];

      '/etc/icinga/':
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0644',
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
        target  => '/etc/icinga/apache2.conf',
#        notify  => Service['apache2'];
      }

  }
  default: {
    fail('You have to define an engine')
  }
}

# caused in errors in duplicate definitions in other modules
#  package { 'apache2':
#    ensure  => present,
#  }
#
#  service  { 'apache2':
#    ensure  => running,
#    require => Package['apache2'];
#  }

  file { "/etc/${target}/nagios_host.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_host.erb'),
    force   => true,
    notify  => Service['nagios']
  }

  file { "/etc/${target}/nagios_hostgroups.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_hostgroups.erb'),
    force   => true,
    notify  => Service['nagios']
  }

  file { "/etc/${target}/nagios_service.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_service.erb'),
    force   => true,
    notify  => Service['nagios']
  }

  file { "/etc/${target}/nagios_servicegroups.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_servicegroups.erb'),
    force   => true,
    notify  => Service['nagios']
  }

  file { "/etc/${target}/nagios_contactgroup.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_contactgroup.erb'),
    force   => true,
    notify  => Service['nagios']
  }

  file { "/etc/${target}/nagios_contact.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_contact.erb'),
    force   => true,
    notify  => Service['nagios']
  }

  file { "/etc/${target}/nagios_timeperiod.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_timeperiod.erb'),
    force   => true,
    notify  => Service['nagios']
  }

#  file { "/etc/${target}/nagios_hostextinfo.cfg":
#    ensure  => file,
#    content => template('nagios/nagios/nagios_hostextinfo.erb'),
#    force   => true,
#    notify  => Service['nagios']
#  }

  file { "/etc/${target}/nagios_command.cfg":
    ensure  => file,
    content => template('nagios/nagios/nagios_command.erb'),
    force   => true,
    notify  => Service['nagios']
  }

  if ($pnp4nagios == 1) {

    package { 'pnp4nagios':
      ensure  => present,
    }

    service { 'npcd':
      ensure  => running,
      require => Package['pnp4nagios'];
    }

    file {'/etc/pnp4nagios':
      ensure  => directory,
      owner   => nagios,
      group   => nagios,
      require => File ["/etc/${target}/nagios_host.cfg"];
    }

    file { ['/var/log/pnp4nagios', '/var/spool/pnp4nagios' ]:
      ensure  => directory,
      owner   => nagios,
      group   => nagios,
      require => [Package['pnp4nagios'],File["/etc/${target}/nagios_host.cfg"]];
    }

    exec { 'mkdir_pnp4nagios_rrdbase':
      path    => [ '/bin', '/usr/bin' ],
      command => "mkdir -p ${pnp4nagios_rrdbase}",
      unless  => "test -d ${pnp4nagios_rrdbase}",
    }

    file { $pnp4nagios_rrdbase:
      ensure  => directory,
      owner   => nagios,
      group   => nagios,
      require => [Exec['mkdir_pnp4nagios_rrdbase'],File["/etc/${target}/nagios_host.cfg"]];
    }

    file {'/etc/pnp4nagios/process_perfdata.cfg':
      ensure  => file,
      content => template('nagios/pnp4nagios/process_perfdata_cfg.erb'),
      force   => true,
      notify  => Service['nagios']
    }

    file {'/etc/pnp4nagios/config_local.php':
      ensure  => file,
      content => template('nagios/pnp4nagios/config_php.erb'),
      force   => true,
    }

    file {'/etc/pnp4nagios/config.php':
      ensure  => file,
      content => template('nagios/pnp4nagios/config_php.erb'),
      force   => true,
    }

    if ($::operatingsystem == 'Ubuntu') {
      file_line { 'npcd_default':
        path    => '/etc/default/npcd',
        line    => 'RUN="yes"',
        match   => '^RUN=.*',
        notify  => Service['npcd'],
        require => Package['pnp4nagios'],
      }
    }

  }
  if ($icli == 1) {

    if ($::operatingsystem in ['OpenSuSE', 'SLES']) {
        package { 'perl-Term-Size':
          ensure  => present,
        }
    }
    elsif ($::operatingsystem == 'Ubuntu') {
        package { 'libterm-size-perl':
          ensure  => present,
        }
    }
    else {
      fail('No supported operating system')
    }

    file {'/usr/local/bin/icli':
      ensure  => file,
      source  => 'puppet:///modules/nagios/nagios/icli',
      force   => true,
      mode    => '0755',
    }
  }
}
