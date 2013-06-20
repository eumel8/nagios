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

  $nagios_server_ip  = '127.0.0.1',
  $engine            = undef,
  $http_users        = {},
  $twilio_account    = undef,
  $twilio_identifier = undef,
  $twilio_from       = undef,
  $twilio_to         = undef

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

        }

        'Ubuntu': {
          $target = 'nagios3'

          package { 'nagios3':
            ensure   => present,
            alias    => 'nagios',
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
        }

        default: {
          error('No supported operating system')
        }
      }

      file {
        [ "/etc/$target/nagios_command.cfg",
          "/etc/$target/nagios_contact.cfg",
          "/etc/$target/nagios_host.cfg",
          "/etc/$target/nagios_timeperiod.cfg",
          "/etc/$target/nagios_hostextinfo.cfg",
          "/etc/$target/nagios_contactgroup.cfg",
          "/etc/$target/nagios_service.cfg",
        ]:
          ensure  => file,
          force   => true,
          owner   => root,
          group   => root,
          mode    => '0644',
          require => File['/etc/nagios'],
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
#          owner   => nagios,
#          group   => nagios,
          mode    => '0750';

        '/usr/share/nagios/htdocs':
          ensure  => directory,
          source  => 'puppet:///modules/nagios/htdocs/nagios/',
          owner   => root,
          group   => root,
          mode    => '0644',
          recurse => true,
          force   => true,
          require => File['/usr/share/nagios'];

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

        '/etc/apache2':
          ensure  => directory;

        '/etc/apache2/conf.d':
          ensure  => directory,
          require => File['/etc/apache2'];

        '/etc/apache2/conf.d/nagios.conf':
          ensure  => 'link',
          target  => '/etc/nagios/apache2.conf',
          require => File['/etc/apache2/conf.d'];
      }
  }

  'icinga': {

    case $::operatingsystem {

      'OpenSuSE': {
        $target = 'nagios'
      }

      'Ubuntu': {
        $target = 'nagios3'
      }

      default: {
        error('No supported operating system')
      }
    }

      file {
        [ "/etc/$target/nagios_command.cfg",
          "/etc/$target/nagios_contact.cfg",
          "/etc/$target/nagios_host.cfg",
          "/etc/$target/nagios_timeperiod.cfg",
          "/etc/$target/nagios_hostextinfo.cfg",
          "/etc/$target/nagios_contactgroup.cfg",
          "/etc/$target/nagios_service.cfg",
        ]:
          ensure  => file,
          force   => true,
          owner   => root,
          group   => root,
          mode    => '0644',
          require => File['/etc/nagios'],
      }

    package {
      'icinga':
        ensure  => installed,
        alias   => 'icinga',
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

      '/var/lib/nagios/rw':
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

      '/usr/share/icinga/htdocs':
        ensure  => directory,
        source  => 'puppet:///modules/nagios/htdocs/icinga/',
        owner   => root,
        group   => root,
        mode    => '0644',
        recurse => true,
        force   => true,
        require => File['/usr/share/icinga'];

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

      '/etc/icinga/apache2.conf':
        ensure  => file,
        source  => 'puppet:///modules/nagios/icinga/apache2.conf',
        force   => true,
        require => Package['icinga'],
        notify  => Service['icinga'];

      '/etc/apache2':
        ensure  => directory;

      '/etc/apache2/conf.d':
        ensure  => directory,
        require => File['/etc/apache2'];

      '/etc/apache2/conf.d/icinga.conf':
        ensure  => 'link',
        target  => '/etc/icinga/apache2.conf',
        require => File['/etc/apache2/conf.d'];
      }
  }
  default: {
    warning('You have to define an engine')
  }
}

#   file { '/etc/nagios3/ext':
#     ensure  => directory,
#     mode    => '0777',
#     content => template('nagios/nagios_ext_services.erb'),
#     force   => true,
#   }


include nagios::command
include nagios::timeperiod
include nagios::contact
include nagios::contactgroup
include nagios::service
include nagios::host

# collect resources and populate /etc/nagios/nagios_*'cfg
Nagios_host <<||>> { 
  target => "/etc/$target/nagios_host.cfg",
  notify => Service['nagios'] 
}
Nagios_service <<||>> { 
  target => "/etc/$target/nagios_service.cfg",
  notify => Service['nagios'],
}
Nagios_hostextinfo <<||>> { 
  target => "/etc/$target/nagios_hostextinfo.cfg",
  notify => Service['nagios'],
}
Nagios_timeperiod <<||>> { 
  target => "/etc/$target/nagios_timeperiod.cfg",
  notify => Service['nagios'],
}
Nagios_command <<||>> { 
  target => "/etc/$target/nagios_command.cfg",
  notify => Service['nagios'],
}
Nagios_contact <<||>> { 
  target => "/etc/$target/nagios_contact.cfg",
  notify => Service['nagios'],
}
Nagios_contactgroup <<||>> { 
  target => "/etc/$target/nagios_contactgroup.cfg",
  notify => Service['nagios'],
}
# Nagios_contact <<||>> { tag => 'server' }
# Nagios_contactgroup <<||>> { tag => 'server' }
File <<| tag == 'nagios_ext_services' |>> {
  notify => Service['nagios']
}
# Package <<||>>

}
