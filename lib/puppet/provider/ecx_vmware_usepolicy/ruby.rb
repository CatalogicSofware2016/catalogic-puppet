require 'net/http'
require 'net/https'
require 'json'
require 'pp'
require 'puppet/provider/ecx'
require 'puppet/provider/connectinfo'

Puppet::Type.type(:ecx_vmware_usepolicy).provide(:ruby, :parent => Puppet::Provider::Ecx) do

# commands :python => 'python'

# def exists?
# end


# def create
#	notice("create:")
# end

# def destroy
#	notice("destroy:")
# end

 def jobstate
	returnval=nil

	policy = resource[:name]
	ecxhost = resource[:ecxhost]
	user = ENV['ECXUSER']
	password = ENV['ECXPASSWORD']

	ci = ConnectInfo.new(ecxhost,user,password)

	jobinfo=ecx_policyjobstatus(ci,policy) 
	if jobinfo != nil
		returnval=jobinfo['status']
		notice("Current status of policy #{policy} is #{returnval}")
	end

	return returnval
 end

 def jobstate=(value)

	returnval = false
 
	policy = resource[:name]
	ecxhost = resource[:ecxhost]
	user = ENV['ECXUSER']
	password = ENV['ECXPASSWORD']
	ivmode = resource[:ivmode]

	ci = ConnectInfo.new(ecxhost,user,password)

	jobinfo=ecx_policyjobstatus(ci,policy) 
	if jobinfo != nil
		ecx_start_use_policy(ci,ivmode,jobinfo)		
	end

	return returnval


 end 
	
end
