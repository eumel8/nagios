# == Class: nagios::params
#
# to develop

class nagios::params {

  $server_pkg_name = $::osfamily ? {
      debian    => 'nagios3',
      opensuse  => 'nagios',
  }

}
