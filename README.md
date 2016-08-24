# ecx-puppet

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ecx](#beginning-with-ecx)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)


## Overview

This puppet module allows you to perform copy data management with Catalogic's ECX product.

## Module Description

Catalogic ECX is a Copy Data Management (CDM) platform that can bring modernization to an existing environment without disruption. ECX delivers “in-place” copy data management to enterprise storage arrays, VMware, and physical machines, Oracle, and MSSQL; allowing the IT team to make use of its existing infrastructure and data in a manner that is efficient, automated, scalable and easy to use. Catalogic ECX allows users to perform data protection, DR, DR testing, sandbox testing of production data for DevOps and continuous integration.  Now, with Catalogic ECX, end-users can get access to the functionality for storage snapshots and replication without having direct access to the storage hardware.  ECX provides an abstraction layer so that end-users do not have to understand or have direct access to underlying hypervisor and storage components.  Also, within ECX, the IT admins can set policies, granular permissions, and quotas to make sure self-service end users don’t go overboard.

Catalogic ECX's performs copy management with VMware, Oracle, MSSQL on popular storage vendors such
as IBM SVC/Storwize/V9000, NetApp, EMC Unity, and AWS Storage Gateway.

This puppet module will allow users to manage ECX Copy Workflow policies that will instantly capture/backup storage volumes, VMware, Oracle and MSSQL databases.  The module will also allow you to initiate ECX VMware Use Data Workflows that will instantly spin-up entire applications in a virtual sandbox environment, or allow you to instantly recover a single VM by name.  

## Setup


### Setup Requirements 

Puppet 3.4 or greater

Ruby 1.9 or greater

Catalogic ECX 2.3 or greater 

(ECX is available as 30 day Free Trial download from http://data.catalogicsoftware.com/ecx-30-day-free-trial-catalogic-software )

### Beginning with ecx

To install module

~~~
puppet module install catalogic-ecx
~~~

## Usage

Set the following environment variables that provide user and password for Catalogic ECX server

~~~
ECXUSER
ECXPASSWORD
~~~

For example

~~~
export ECXUSER=admin
export ECXPASSWORD=mypassword123
~~~

This module provides three different puppet provider types ecx_copypolicy, ecx_vmware_usepolicy, and ecx_instantvm

**ecx_copypolicy** - This will allow users to start a ECX Copy Data Policy.  An ECX Copy Data policy will capture or backup storage volumes, VMware Virtual Machines, or Applications such as Oracle and MSSQL using storage array snapshots and storage array replication.

How to start a ecx_copypolicy. Here we are starting a ECX Use Policy named "SalesApp" on a particular Catalogic ECX server whose ip address is 172.20.50.11 and have specfied the "gold" storage workflow.  Note that the ECX Copy Data Policy and ECX storageworkflow should be created in ECX beforehand.

~~~
ecx_copypolicy {

'SalesApp' :
        jobstate => 'ACTIVE',
        ecxhost => '172.20.50.11',
        ecxstorageworkflow => 'gold',
}
~~~

How to appy the manifest.  For example, place the desired manifest in the file example1.pp and run the following puppet apply command.
~~~
puppet apply ./example1.pp
~~~

**ecx_vmware_usepolicy** - This will allow users to start a ECX VMware Use Data Policy.  An ECX VMware Use Data Policy will instantly spin-up virtual machines specified in the policy.  Note that this policy should be created on the ECX server beforehand.   There are three parameters that need to specified: jobstate, ivmode, and ecxhost.  The jobstate should be set to "ACTIVE".  For ivmode, allowed values are: “test”, “end_iv”, “clone” and “rrp”. Specifying “test” for ivmode spins up the virtual machine in a test sandbox from cloned snapshots, under a different name then the production vm. Specifying  "end_iv" for ivmode will clean up the test vm resources.  Specifying "clone" for ivmode will create a test vm on permanent storage. Specifying “rrp” for  ivmode, the original production virtual machines will be deleted, new virtual machines created and storage will be mapped to cloned snapshot.  In the background, a storage vMotion wll be started to move the vmdk data from snapshot clones to production storage.

The following example manfiest shows a Use Data Policy named "devop2" and starting in the ivmode set to "test" and ecxhost set to "172.20.50.8".

~~~
ecx_vmware_usepolicy {

'devop2' :
        jobstate => 'ACTIVE',
        ivmode => 'test',
        ecxhost => '172.20.50.8',
}
~~~



The following example manifest shows a Use Data Policy named "devop2" where ivmode is set to "end_iv", which will clean up test resources

~~~
ecx_vmware_usepolicy {

'devop2' :
        jobstate => 'ACTIVE',
        ivmode => 'end_iv',
        ecxhost => '172.20.50.8',
}
~~~

The following example manifest shows a Use Data Policy named "devop2" which will create cloned virtual machine(s).

~~~
ecx_vmware_usepolicy {

'devop2' :
        jobstate => 'ACTIVE',
        ivmode => 'clone',
        ecxhost => '172.20.50.8',
}
~~~

The following example manifest shows a Use Data Policy named "devop2" that will create a production environment.  In this case, ECX will delete the production VM, and create a new VM from cloned storage.  In the background, the VM storage will be vMotioned to production storage.

~~~
ecx_vmware_usepolicy {

'devop2' :
        jobstate => 'ACTIVE',
        ivmode => 'rrp',
        ecxhost => '172.20.50.8',
}
~~~


**ecx_instantvm** - This provider type will allow users to spin-up or recover individual virtual machines by name.  For ivmode, allowed values are “ test”, “end_iv”, “clone” and “rrp”. Specifying “test” for ivmode spins up the virtual machine in test sandbox from cloned snapshots, under a different name then production vm. Specifying  "end_iv" for ivmode will clean up the test vm resources.  Specify "clone" for ivmode will create a test vm on permanent storage. Specifying “rrp” for  ivmode, the original production virtual machines will be deleted, new virtual machines created and storage will be mapped to cloned snapshot.  In the background, a storage vMotion wll be started to move the vmdk data from snapshot clones to production storage. 

The following example shows ecx_instantvm where ivmode is set to “test”.  

~~~
ecx_instantvm {

'myvmname' :
        ivmode => 'test',
        vcenter => 'Dev2Vcenter',
        ecxhost => '172.20.50.8',
}
~~~

The following example shows ecx_instantvm where ivmode is set to test:

~~~
ecx_instantvm {

'myvmname' :
        ivmode => 'test',
        vcenter => 'Dev2Vcenter',
        ecxhost => '172.20.50.8',
}
~~~

Please see the “tests” directory, example manifests are provided.

## Reference

* `ecx_copypolicy`:Catalogic ECX Copy Policy Management
* `ecx_vmware_usepolicy`: Catalogic ECX Use Policy Management
* `ecx_instantvm`: Allows users to instantly recover virtual machine by name

## Limitations

This module requires Catalogic ECX 2.4,  Ruby 1.9 or later and is only tested on Puppet versions 3.4 and later.







