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

  nagios_contactgroup{'group_email':
    members  => 'email',
  }
  nagios_contactgroup{'group_sms':
    members  => 'sms',
  }
  nagios_contactgroup{'group_voice':
    members  => 'voice',
  }

}
