Puppet::Type.newtype(:ecx_instantvm) do


	newparam(:name, :namevar => true) do
	end

	newproperty(:ivmode) do
		desc 'set the mode of Virtual Machine during Instant Virtualization'
		validate do |value|
			unless value == "clone" or value == "end_iv" or value == "test"
				raise ArgumentError, "ivmode must have the following value: test | end_iv | clone | rrp " 
			end
		end
	end

	newparam(:vcenter) do
		desc 'The name of the VMware vCenter where the VM resides'

		validate do |value|
			unless value != ""
				raise ArgumentError, "vcenter must be set to name of vCenter" 
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

end

