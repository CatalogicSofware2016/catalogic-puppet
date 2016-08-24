Puppet::Type.newtype(:ecx_copypolicy) do

	newparam(:name, :namevar => true) do
	end

	newproperty(:jobstate) do
		desc 'Change the state of the ECX Copy Policy Job'
		validate do |value|
			unless value == "ACTIVE"
				print value
				raise ArgumentError, "jobstate must be set to ACTIVE"  % value
			end
		end

	end

	newparam(:ecxhost) do
		desc 'The ECX server hostname or ipaddress'
		validate do |value|
			unless value != ""
				raise ArgumentError, "ecxhost must be set to the ECX server hostname or ipaddress" % value 
			end
		end
			
	end

	newparam(:ecxstorageworkflow) do
		desc 'The storage workflow name that will used in copy workflow job'
		validate do |value|
			unless value != ""
				raise ArgumentError, "ecxstorageworkflow cannot be empty" % value 
			end
		end


	end

	validate do
    		raise ArgumentError, "ecxhost must be specified" if self[:ecxhost]==nil
    		raise ArgumentError,  "ecxstorageworkflow must be specified" if self[:ecxstorageworkflow]==nil
    		raise ArgumentError,  "jobstate must be specified" if self[:jobstate]==nil
  	end


end

