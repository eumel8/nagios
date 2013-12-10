# == Class: nagios::contact
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

class nagios::contact {

#  nagios_contact{'email':
#    service_notification_period     => '24x7',
#    host_notification_period        => '24x7',
#    service_notification_options    => 'w,u,c,r',
#    host_notification_options       => 'd,r',
#    service_notification_commands   => 'notify-service-by-email',
#    host_notification_commands      => 'notify-host-by-email',
#    email                           => 'root@localhost',
#  }
  nagios_contact{'sms':
    service_notification_period     => '24x7',
    host_notification_period        => '24x7',
    service_notification_options    => 'w,u,c,r',
    host_notification_options       => 'd,r',
    service_notification_commands   => 'notify-service-by-sms',
    host_notification_commands      => 'notify-host-by-sms',
  }
  nagios_contact{'voice':
    service_notification_period     => '24x7',
    host_notification_period        => '24x7',
    service_notification_options    => 'w,u,c,r',
    host_notification_options       => 'd,r',
    service_notification_commands   => 'notify-service-by-voice',
    host_notification_commands      => 'notify-host-by-voice',
  }

}
