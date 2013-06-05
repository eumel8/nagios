require 'etc'
Facter.add(:nagios_ext_services) do
  setcode do
     servicelist = Array.new
     nagios_ext_services  = "/etc/nagios/nagios_ext_services.cfg"
     if File.exists?(nagios_ext_services) then
           File.readlines(nagios_ext_services).each { |line|
             servicelist << line.chomp
           } 
     end 
  end
end
