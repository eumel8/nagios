# == Class: nagios::command
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

class nagios::command {

  nagios_command{'check_nrpe':
    command_line  => '/usr/lib/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -a $ARG2$',
  }
  nagios_command{'check_nrpe_1arg':
    command_line  => '/usr/lib/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$',
  }
  nagios_command{'check_ping':
    command_line  => '/usr/lib/nagios/plugins/check_ping -H $HOSTADDRESS$ -w $ARG1$ -c $ARG2$',
  }
  nagios_command{'check-host-alive':
    command_line  => '/usr/lib/nagios/plugins/check_ping -H "$HOSTADDRESS$" -w 5000,100% -c 5000,100% -p 1',
  }
  nagios_command{'check_tcp':
    command_line  => '/usr/lib/nagios/plugins/check_tcp -H $HOSTADDRESS$ -p $ARG1$',
  }
  nagios_command{'check_smtp':
    command_line  => '/usr/lib/nagios/plugins/check_smtp -H $HOSTADDRESS$ -p $ARG1$',
  }
  nagios_command{'check_http':
    command_line  => '/usr/lib/nagios/plugins/check_http -H $HOSTADDRESS$ -I $HOSTADDRESS$',
  }
  nagios_command{'notify-host-by-email':
    command_line  => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\nHost: $HOSTNAME$\nState: $HOSTSTATE$\nAddress: $HOSTADDRESS$\nInfo: $HOSTOUTPUT$\n\nDate/Time: $LONGDATETIME$\n" | /usr/bin/mail -s "** $NOTIFICATIONTYPE$ Host Alert: $HOSTNAME$ is $HOSTSTATE$ **" $CONTACTEMAIL$',
  }

# neuerdings doppelt
#  nagios_command{'notify-service-by-email':
#    command_line  => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\n\nService: $SERVICEDESC$\nHost: $HOSTALIAS$\nAddress: $HOSTADDRESS$\nState: $SERVICESTATE$\n\nDate/Time: $LONGDATETIME$\n\nAdditional Info:\n\n$SERVICEOUTPUT$\n" | /usr/bin/mail -s "** $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **" $CONTACTEMAIL$',
#  }

  nagios_command{'notify-host-by-voice':
    command_line  => '/etc/nagios/scripts/twilio_voice.sh "Hello. This is your Network Operation Center. $NOTIFICATIONTYPE$ Host Alert: $HOSTNAME$ is $HOSTSTATE$ **"',
  }

  nagios_command{'notify-service-by-voice':
    command_line  => '/etc/nagios/scripts/twilio_voice.sh "Hello. This is your Network Operation Center. $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **"',
  }

  nagios_command{'notify-host-by-sms':
    command_line  => '/etc/nagios/scripts/twilio_sms.sh "NOC Message. $NOTIFICATIONTYPE$ Host Alert: $HOSTNAME$ is $HOSTSTATE$ **"',
  }

  nagios_command{'notify-service-by-sms':
    command_line  => '/etc/nagios/scripts/twilio_sms.sh "NOC Message. $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **"',
  }

  nagios_command{'process-host-perfdata':
    command_line  => '/usr/bin/printf "%b" "$LASTHOSTCHECK$\t$HOSTNAME$\t$HOSTSTATE$\t$HOSTATTEMPT$\t$HOSTSTATETYPE$\t$HOSTEXECUTIONTIME$\t$HOSTOUTPUT$\t$HOSTPERFDATA$\n" >> /var/lib/nagios3/host-perfdata.out',
  }
  nagios_command{'process-service-perfdata':
    command_line  =>  '/usr/bin/printf "%b" "$LASTSERVICECHECK$\t$HOSTNAME$\t$SERVICEDESC$\t$SERVICESTATE$\t$SERVICEATTEMPT$\t$SERVICESTATETYPE$\t$SERVICEEXECUTIONTIME$\t$SERVICELATENCY$\t$SERVICEOUTPUT$\t$SERVICEPERFDATA$\n" >> /var/lib/nagios3/service-perfdata.out',
  }

}
