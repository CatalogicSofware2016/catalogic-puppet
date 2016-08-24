require 'puppet/provider'
require 'net/http'
require 'net/https'
require 'json'
require 'pp'
require 'puppet/provider/connectinfo'
require 'uri'


class Puppet::Provider::Ecx < Puppet::Provider

	def get_sessionid(ci)
		http = Net::HTTP.new(ci.server,8443)
		req = Net::HTTP::Post.new("/api/endeavour/session")
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		req.basic_auth ci.user, ci.password
		response = http.request(req)
		return response.body
	end

	def makeget(ci)
		debug "ECX:makeget: #{ci.path}"

		req = Net::HTTP::Get.new(ci.path)
		req.add_field("x-endeavour-sessionid",ci.sessionid)

		connection =  Net::HTTP.new(ci.server,8443)
		connection.use_ssl = true
		connection.verify_mode = OpenSSL::SSL::VERIFY_NONE

		res = connection.start do |http|
			http.request(req)
		end

		return res.body
 	end

 	def make_get_full_path(ci)
		debug "ECX:make_get_full_path: Enter #{ci.path}"
		
		uri = URI.parse(ci.path)	

		if(uri.query!=nil)
			req = Net::HTTP::Get.new(uri.path+"?"+uri.query)
		else
			req = Net::HTTP::Get.new(uri.path)
		end
	
		req.add_field("x-endeavour-sessionid",ci.sessionid)

		connection =  Net::HTTP.new(uri.host,uri.port)
		connection.use_ssl = true
		connection.verify_mode = OpenSSL::SSL::VERIFY_NONE


		res = connection.start do |http|
			http.request(req)
		end

		debug "ECX:make_get_full_path: Exit #{ci.path}"
		return res.body
 	end

	def make_post_full_path(ci,postdata)
		debug "ECX:makepost:enter: #{ci.path}"

		uri = URI.parse(ci.path)

		header = {'Content-Type' =>'application/json'}
		req = Net::HTTP::Post.new(ci.path,header)
		req.add_field("x-endeavour-sessionid",ci.sessionid)
		
		req.body = postdata

		connection =  Net::HTTP.new(ci.server,8443)
		connection.use_ssl = true
		connection.verify_mode = OpenSSL::SSL::VERIFY_NONE

		res = connection.start do |http|
			http.request(req)
		end

		return res.body
 	end
 

	def makepost(ci,postdata)
		debug "ECX:makepost:enter: #{ci.path}"

		header = {'Content-Type' =>'application/json'}
		req = Net::HTTP::Post.new(ci.path,header)
		req.add_field("x-endeavour-sessionid",ci.sessionid)
		
		req.body = postdata

		connection =  Net::HTTP.new(ci.server,8443)
		connection.use_ssl = true
		connection.verify_mode = OpenSSL::SSL::VERIFY_NONE

		res = connection.start do |http|
			http.request(req)
		end


		return res.body
 	end
 



 	def ecx_policyexist(ci,ecxpolicy)
		debug "ECX:ecx_policyexist: Enter"

  		response=get_sessionid(ci)
		sessioninfo = JSON.parse(response)

		# make call to get list of policies
		ci.sessionid=sessioninfo['sessionid']
		ci.path="/api/endeavour/job"
		response=makeget(ci)
		responsejson = JSON.parse(response)	

		responsejson['jobs'].each do |job|
			if job['name'] == ecxpolicy 
				notice("Found ECX policy with name:  #{job['name']}")
			end
		end	


	end


	#
	# Let's check to see if there's already a copy policy job running
	#
 	def ecx_policyjobstatus(ci,ecxpolicy)
		debug "ecx_policyjobstatus: Enter"
		returnval = nil

		response=get_sessionid(ci)
		sessioninfo = JSON.parse(response)

		if(sessioninfo['sessionid']!=nil)
		

			# make call to get list of policies
			ci.sessionid=sessioninfo['sessionid']
			ci.path="/api/endeavour/job"
			response=makeget(ci)
			responsejson = JSON.parse(response)	

			responsejson['jobs'].each do |job|
				if job['name'] == ecxpolicy 
					notice("Found job associated with policy #{ecxpolicy}")
					returnval = job
				end	
			end
		else
			notice("Error: Unable to obtain ECX SessionId")
		end

		return (returnval)
	end


 	def ecx_startcopypolicyjob(ci,in_storageworkflow,jobdetail)

		debug "ecx_startcopypolicyjob: Enter"

		policyid=jobdetail['policyId']
		ci.path = "/api/endeavour/policy/"+policyid
		response=makeget(ci)

		policydetail=JSON.parse(response)


		storageworkflows=policydetail['spec']['storageworkflow']

		swid=nil
		storageworkflows.each do |sw|
			if sw['name']==in_storageworkflow
                swid=sw['id']
                notice("Found a valid storage workflow with name=#{sw['name']}")
			end
		end

		# Now we got the storagworkflow id, let's start the copy policy
		#pp jobdetail
		jobinfo={}
		jobinfo['actionname']=swid
		ci.path ="/api/endeavour/job/"+jobdetail['id']+"?action=start&actionname=start"
		startjobresponse=makepost(ci,jobinfo.to_json)
		
		if startjobresponse != nil
			jobresp = JSON.parse(startjobresponse)
			if jobresp != nil
					notice("Successfully started job #{jobresp['name']}")
			end
		else
			notice("Failed to start copy policy")
		end
	end

	def ecx_start_use_policy(ci,ivmode,jobdetail)

		debug "ecx_startusepolicyjob: Enter"


		jobinfo={}
	
		if jobdetail['status']=="ACTIVE"
			notice("Job is ACTIVE, no mode change")
		elsif jobdetail['status']=="PENDING" && ( ivmode=="clone" || ivmode=="rrp"  || ivmode=="end_iv" )

			notice("Job status is PENDING,looking to see if policy has any active job sessions")

			#get live job session 
			ci.path=jobdetail['links']['livejobsessions']['href']
			response=make_get_full_path(ci)
			livejobsession= JSON.parse(response)

		    sessions = livejobsession['sessions']	

			activesession=nil
			sessions.each do |session|
				notice("Looking through each session ")
				if session['status'] == "PENDING" && session['results'] == "IV test active"
					notice("Found job session that is in IV test active, let's convert the mode to #{ivmode}")
					activesession=session
					#pp activesession
					break
				end
			end

			notice("Let's check if activesession is valid, changing to mode #{ivmode}")

#			pp activesession
			if activesession!=nil
				notice("ivmode is #{ivmode}")

				if ivmode=="clone"
					notice("Converting IV test to clone")
					ci.path = activesession['links']['clone']['href']
				elsif ivmode=="rrp"
					notice("Converting IV test to Rapid Return to Production")
					ci.path = activesession['links']['rrp']['href']
				elsif ivmode=="end_iv"
					notice("Cleaning up resources for IV test and stopping job session")
					notice("before env_iv link")
					#pp activesession
					ci.path = activesession['links']['end_iv']['href']
					notice("after env_iv link")
				else
					fail("Error: Could not find link to change job session mode")
				end

				notice("Change the job mode")

				notice("before calling make_post_full")
				response=make_post_full_path(ci,jobinfo.to_json)
				notice("before JSON parse")
				jobresp=JSON.parse(response)
				notice("after JSON parse")

				if jobresp != nil
					if jobresp['id'] != nil
						jobid=jobresp['jobId']
						notice("Success, changed  jobId #{jobid} to  mode: #{ivmode}")
					else
						notice("Failed to change job mode, invalid job session return")
					end
				else
					notice("Failed to change job mode")
				end
			else
				notice("No active job sessions found for Pending Job, mode not changed")
			end
		elsif jobdetail['status']!="PENDING" && ivmode=="end_iv"
			notice("No need to change to end_iv mode, policy job is already in end_iv")
		else
			notice("No active job sessions, start new job session")
			ci.path ="/api/endeavour/job/"+jobdetail['id']+"?action=start&actionname=start_#{ivmode}_iv"
			jobresponse=makepost(ci,jobinfo.to_json)
			jobresp= JSON.parse(jobresponse)
			if jobresp != nil
				if jobresp['id'] != nil
					jobid=jobresp['id']
					notice("Success, started new job #{jobid} with mode: #{ivmode}")
				else
					notice("Failed to change job mode, invalid job session return")
				end
			else
				notice("Failed to change job mode")
			end

		end



	end


	def get_vminfo(ci,in_vcenter,in_vmname,in_ivmode)

		notice("get_vminfo: Enter")

		response=get_sessionid(ci)
		sessioninfo = JSON.parse(response)

		if(sessioninfo['sessionid']!=nil)
				
				# make call to get list of policies
				ci.sessionid=sessioninfo['sessionid']

				#
				# get list of registered vCenters
				#

				ci.path = "/api/vsphere"
				response=makeget(ci)
				parsed=JSON.parse(response)
				#pp parsed

				recovervmlist=Array.new
				recovervm={}


				#
				# get info about use vm that needs to get recovered
				#

				notice("Searching for vCenter #{in_vcenter}")
				vcenters = parsed['vspheres']
				vcenters.each do |vcenter|
					notice("Does the following vCenter match #{vcenter['name']}")
					site = vcenter['siteName']
					vmlisturl = vcenter['links']['vms']['href']
					if vcenter['name']==in_vcenter
						ci.path = vmlisturl
						response=make_get_full_path(ci)
						vmresponse = JSON.parse(response)
						#pp vmresponse
						vmlist=vmresponse['vms']
						vmlist.each do |vm|
	#							pp  vm['name']
								if vm['name']==in_vmname
										recovervm['vm']=vm
										recovervm['vcenter']=vcenter
										recovervmlist.push(recovervm)
										notice("Yes, I found the VM that needs to be recovered")
										#pp recovervm
								end
						end
					end
				end

				
				notice("I found #{recovervmlist.count}")
				recover_vm(ci,recovervmlist,in_ivmode)

		end # if session
	end # end of get_vminfo




	def recover_vm(ci,in_recovervmlist,in_ivmode)

		notice("recover_vm: Enter")

		uniqueid="123"

		policy={}
		spec={}
		sourcelist=[]
		source={}
		subpolicylist=[]
		subpolicy={}


		policy['description']=""
	
		policy['logicalDelete']=false
		policy['name']= "Puppet_InstantVM_"+resource[:name]
		policy['serviceId']="com.syncsort.dp.xsb.serviceprovider.recovery.vmware"


		in_recovervmlist.each do |vm|	

        	# build source

        	source['href']=vm['vm']['links']['self']['href']+"?time=0"
        	source['id']=vm['vm']['id']
        	source['include']=true
        	source['resourceType']="vm"
        	version={}
        	version['href']=vm['vm']['links']['self']['href']+ "/version/latest?time=0"
        	version['metadata']=JSON.parse('{"id": "latest", "name": "Use Latest"}')
        	source['version']=version

        	#add source to spec
        	spec['notification'] = []
        	sourcearray=[source]
        	spec['source']=sourcearray


        	#build subpolicy
        	subpolicy['description']= ""
        	subpolicy['name']="subpolicy1"


			subpolicy['option']={}
        	subpolicy['option']['allowsessoverwrite']=true
			subpolicy['option']['autocleanup']=true
			subpolicy['option']['continueonerror']=true

			subpolicy['option']['mode']="test"

			subpolicy['option']['poweron']=false
			#subpolicy['option']['poweron']=true

			

		#	subpolicy['destination']={}
		#	subpolicy['destination']['mapsubnet']={}
		#	subpolicy['destination']['mapsubnet']['x.x.x.x']={}
		#	subpolicy['destination']['mapsubnet']['x.x.x.x']['dhcp']=false

		#	subpolicy['destination']['mapsubnet']['x.x.x.x']['dnslist']=[]
		#	subpolicy['destination']['mapsubnet']['x.x.x.x']['dnslist'].push("172.20.2.2")

		#	subpolicy['destination']['mapsubnet']['x.x.x.x']['gateway']="172.20.0.254"
	   	#	subpolicy['destination']['mapsubnet']['x.x.x.x']['subnet']="172.20.50.13"
		#	subpolicy['destination']['mapsubnet']['x.x.x.x']['subnetmask']="255.255.0.0"
	

			subpolicysource={}
			subpolicysource['copy']={}
			subpolicysource['copy']['site']={}
			subpolicysource['copy']['href']={}

			subpolicysource['copy']['site']['href']= vm['vcenter']['links']['site']['href']
			subpolicysource['primarysource']=true	
#			pp subpolicysource


        	subpolicy['source']=subpolicysource
        	subpolicy['type']="IV"

        	subpolicylist.push(subpolicy)
		
        	spec['subpolicy']=subpolicylist

        	policy['spec']=spec

        	policy['subType']="vmware"
        	policy['type']="recovery"
        	policy['version']="2.0"
		end
#		puts JSON.pretty_generate(policy)





		#
		# create the policy
		#

		notice("Creating VMWare Use Data Policy")
		ci.path ="/api/endeavour/policy"

		postdata=policy.to_json
		response=makepost(ci,postdata)
		policyresponse=JSON.parse(response)
		#pp policyresponse

		policyid=policyresponse['id']
		print "Created Use Data Policy with Id="+policyid


		#
		# create the job for the policy
		#

		job={}

		job['name']=policy['name']
		job['policyId']=policyresponse['id']

		ci.path="/api/endeavour/job"
		response=makepost(ci,job.to_json)
		jobresponse=JSON.parse(response)

		notice("Created Job with Id=#{jobresponse['id']}")

		#
		# Let's start the recovery job with the specified mode 
		#
		
		pp policy['name']
#		jobinfo=ecx_policyjobstatus(ci,policy['name'])
#
#		if jobinfo != nil
#			if jobinfo['status']!="ACTIVE"
#				notice("Starting use policy job since there is none running")	
#                		ecx_start_use_policy(ci,in_ivmode,jobinfo)
##			end
#		else
#			notice("Job info is nil")
#		end

		

	end # end recover_vm


end # end of class


