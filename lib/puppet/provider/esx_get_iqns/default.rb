# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_get_iqns).provide(:esx_get_iqns, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter CIFS/NFS (file) datastores."

 def get_esx_iqns
		iqnlist = Array.new 
		command = "/usr/bin/esxcli --server=#{resource[:host]} --username=#{resource[:hostusername]}  --password=#{resource[:hostpassword]} iscsi adapter list"
		servers = nil
		hbalist = Array.new
		begin
				IO.popen(command) do |servers|
					servers.each do |hbas|
						if !(hbas.include? "unbound") and !(hbas.include? "-------") and !(hbas.include? "Description")
							hbalist.push hbas.split[0]							
						end	
					end
				end
				if hbalist.size > 0
					iqnlist = get_iqn(hbalist)
				else
				puts "Could not find any IQNS from given host server"
				end								
		rescue Exception => excep
			Puppet.err "Unable to perform the operation because the following exception occurred - "
			Puppet.err excep.message
		end
  return iqnlist		
  end
  
   def get_esx_iqns=(value)
         puts "get_esx_iqns:#{value}"	 
   end 
	def get_iqn( hbalist)
		iqns = Array.new 
		hbalist.each do |hba|
			newcommand = "/usr/bin/esxcli --server=#{resource[:host]} --username=#{resource[:hostusername]}  --password=#{resource[:hostpassword]} iscsi adapter get -A  #{hba}"  
			IO.popen(newcommand) do |server|
				server.each do |iqn|
					puts iqn
					if iqn.include? "Name:" and !(iqn.include? "Driver Name:")
						matchdata = iqn.match(/([^>]*): ([^>]*)/)								
						iqns.push matchdata[2]								
					end
				end
			end						
		end
		return iqns
	end  
 
  def create       
  end

  def destroy	
  end
  
  def exists? 
  return true  
  end
end