require 'etc'
Facter.add(:nagios_ext_services) do
  setcode do
     servicelist = Array.new
     nagios_ext_services  = "/etc/nagios/nagios_ext_services.cfg"
     if File.exists?(nagios_ext_services) then
        data = File.open(nagios_ext_services).read
	data.each_line do  |line|
	  servicelist << line
	end
     end 
  end
end
