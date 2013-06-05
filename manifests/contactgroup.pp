# == Class: nagios::contactgroup
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

class nagios::contactgroup {

  nagios_contactgroup{'admins2':
    members  => 'boot',
  }

}
