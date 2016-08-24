
#ivmode => 'clone',
#ivmode => 'end_iv',
#ivmode => 'test',

ecx_vmware_usepolicy {

'devop2' :
	jobstate => 'ACTIVE',
	ivmode => 'test',
	ecxhost => '172.20.50.8',
}
	

