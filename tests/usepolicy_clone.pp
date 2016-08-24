
#ivmode => 'clone',
#ivmode => 'end_iv',
#ivmode => 'test',

ecx_vmware_usepolicy {

'devop2' :
	jobstate => 'ACTIVE',
	ivmode => 'end_iv',
	ecxhost => '172.20.50.8',
}
	

