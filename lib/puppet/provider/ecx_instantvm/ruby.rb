require 'net/http'
require 'net/https'
require 'json'
require 'pp'
require 'puppet/provider/ecx'
require 'puppet/provider/connectinfo'

Puppet::Type.type(:ecx_instantvm).provide(:ruby, :parent => Puppet::Provider::Ecx) do

 #commands :python => 'python'

# def exists?
# end


# def create
#	notice("create:")
# end

# def destroy
#	notice("destroy:")
# end

 def ivmode
	returnval=nil

	vmname = resource[:name]
	vcenter = resource[:vcenter]
	ecxhost = resource[:ecxhost]
	user = ENV['ECXUSER']
	password = ENV['ECXPASSWORD']
	ivmode=resource[:ivmode]	

	ci = ConnectInfo.new(ecxhost,user,password)

	policy= "Puppet_InstantVM_"+resource[:name]

	jobinfo=ecx_policyjobstatus(ci,policy)
	pp jobinfo
        if jobinfo != nil
                returnval=jobinfo['status']
                notice("Current status of policy #{policy} is #{returnval}")
	else	
		returnval="IDLE"
        end

	return returnval
 end

 def ivmode=(value)

	returnval = false
 
	vmname = resource[:name]
	vcenter = resource[:vcenter]
	ecxhost = resource[:ecxhost]
	user = ENV['ECXUSER']
	password = ENV['ECXPASSWORD']
	ivmode=resource[:ivmode]	

	ci = ConnectInfo.new(ecxhost,user,password)

	policy= "Puppet_InstantVM_"+resource[:name]

	jobinfo=ecx_policyjobstatus(ci,policy)
        if jobinfo == nil
                notice("Could not find InstantVM policy, so creating new policy")

		#
		# get vm info and create policy and job
		#
		get_vminfo(ci,vcenter,vmname,ivmode)

		#
		# start the job
		#
		jobinfo=ecx_policyjobstatus(ci,policy)
	 	ecx_start_use_policy(ci,ivmode,jobinfo)
	else
 		ecx_start_use_policy(ci,ivmode,jobinfo)
	end


	return returnval


 end 
	
end
