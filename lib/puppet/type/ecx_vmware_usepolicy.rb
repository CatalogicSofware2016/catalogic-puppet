Puppet::Type.newtype(:ecx_vmware_usepolicy) do


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

	newparam(:ivmode) do
		desc 'set the mode of ECX Use Policy Job'
		validate do |value|
			unless value == "clone" or value == "end_iv" or value == "test"
				raise ArgumentError, "ivmode must have the following value: test | end_iv | clone | rrp " 
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

	validate do
                raise ArgumentError, "ecxhost must be specified" if self[:ecxhost]==nil
                raise ArgumentError,  "ivmode must be specified" if self[:ivmode]==nil
                raise ArgumentError,  "jobstate must be specified" if self[:jobstate]==nil
	end


	

end

