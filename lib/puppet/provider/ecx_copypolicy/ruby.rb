require 'net/http'
require 'net/https'
require 'json'
require 'pp'
require 'puppet/provider/ecx'
require 'puppet/provider/connectinfo'

Puppet::Type.type(:ecx_copypolicy).provide(:ruby, :parent => Puppet::Provider::Ecx) do

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

	storageworkflow = resource[:ecxstorageworkflow]

	ci = ConnectInfo.new(ecxhost,user,password)

	jobinfo=ecx_policyjobstatus(ci,policy) 

	if jobinfo != nil
		returnval=jobinfo['status']
		notice("Obtained job status = #{returnval}")
	end

	return returnval
 end

 def jobstate=(value)

	returnval = false
 
	policy = resource[:name]
	ecxhost = resource[:ecxhost]
	user = ENV['ECXUSER']
	password = ENV['ECXPASSWORD']
	storageworkflow = resource[:ecxstorageworkflow]

	ci = ConnectInfo.new(ecxhost,user,password)

	jobinfo=ecx_policyjobstatus(ci,policy) 
	if jobinfo != nil
		# if policy not active, let's start it 
		if jobinfo['status'] != 'ACTIVE'
			ecx_startcopypolicyjob(ci,storageworkflow,jobinfo)		
		else
			notice("Policy #{policy} is already in ACTIVE mode")
		end	

	end

	return returnval


 end 
	
end
