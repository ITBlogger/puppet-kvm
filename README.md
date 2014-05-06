# puppet-kvm

Puppet module to control libvirt/kvm VMs and to build up a webvirtmgr system to manage the libvirt hypervisors. This module currently only works for CentOS/RedHat and requires hiera,
the Puppet Labs Firewall module and their vcsrepo module as well. It is currently pretty crude and should only be used for a test or lab environment. Currently, only bridging of VMs is supported. kvm::virtnet class
would have to be extended to allow for natted or other VM networking types. The libvirt hosts and the webvirtmgr host need to have internet connectivity currently for this to work.

######TODO: Use hieragpg for passwords
######TODO: Add validation for most paramaters
######TODO: Add rspec tests
######TODO: Make it work with Debian at the very least

## Overview

This module configures virtual networks, VM storage pools, VM storage volumes and VMs on KVM/libvirt hypervisor hosts and configures webvirtmgr on a separate system to manage the hypervisors and VMs.

Webvirtmgr can be found at https://github.com/retspen/webvirtmgr

## Class: kvm

Main class that calls the various subclasses based on the 'kvmservertype' parameter.

### Parameters

 * 'kvmservertype'	(valid values are 'kvm' and 'kvmwebmgr')
 * 'virtpool_hash'	(hiera hash used for setting up libvirt storage pools)
 * 'virtvol_hash'	(hiera hash used for setting up libvirt volumes)
 * 'virts_hash'		(hiera hash used for setting up libvirt VMs)
 * 'hypervisorpass'	(password used to connect to hypervisors over TCP, required to allow webvirtmgr connectivity to hosts and VMs)
 
## Class: kvm::fw

Configures iptables firewall to allow the various connections required for libvirt and webvirtmgr. Requires the Puppet Labs Firewall module to work.

## Class: kvm::kvmwebmgr

Installs depencies for webvirtmgr, installs webvirtmgr and configures everything to make it work. As written, it requires internet connectivity to pull down webvirtmgr. 

## Definition: kvm::virtnet

Sets up virtual network to be used by VMs on a host

### Parameters

 * 'virtnet_name'			(required, comes from virtnet_hash hiera hash)
 * 'virtnet_forwardmode'	(default is 'bridge') 
 * 'virtbridge_name'		(required, comes from virtnet_hash hiera hash)
 * 'virtnet_macaddress'		(required, comes from virtnet_hash hiera hash)
 
## Definition: kvm::virtpool

Sets up virtual storage pools to be used by VMs and for ISO storage on a host

### Parameters

 * 'virtpool'
 * 'virtpool_target'	(required, default is '/var/lib/libvirt/images')
 * 'virtpool_type'		(required, default is 'dir', can be any storage pool type allowed by libvirt such as 'iso')
 * 'virtpool_format'	(required, default is 'raw', can be any storage pool format allowed by libvirt)

## Definition: kvm::virts

Sets up virtual machines on a libvirt/kvm host

### Parameters

 * 'vmname'			(required, comes from virts_hash hiera hash, usually set as short hostname for vm)
 * 'desc'			(comes from virts_hash hiera hash, usually set as FQDN for vm)
 * 'pool'           (required, default is 'default', can be overridden in virts_hash)
 * 'poolpath'       (required, default is '/var/lib/libvirt/images', can be overridden in virts_hash)
 * 'virttype'       (required, default is 'kvm', can be overridden in virts_hash)
 * 'virtcpus'       (required, default is '1', can be overridden in virts_hash)
 * 'virtmem'        (required, default is '1024', can be overridden in virts_hash)
 * 'virtostype'     (required, default is 'linux', can be overridden in virts_hash)
 * 'virtosvariant'  (required, default is 'virtio26', can be overridden in virts_hash)
 * 'virtprovider'   (required, default is 'libvirt', can be overridden in virts_hash)
 * 'virtnic'        (required, default is 'virtio', can be overridden in virts_hash)
 * 'virtnet'        (required, default is 'br0', can be overridden in virts_hash)
 * 'virtmac'        (required, default is '\"RANDOM\"', can be overridden in virts_hash)
 * 'cdrom_location' (required, default is '/var/lib/libvirt/iso-images/CCELinux-6.4.1.iso', can be overridden in virts_hash)
 * 'pxe'            (required, default is 'true', can be overridden in virts_hash)
 * 'autoboot'       (required, default is 'true', can be overridden in virts_hash)
 * 'alwayson'       (required, default is 'true', can be overridden in virts_hash)

## Definition: kvm::virtvol

Sets up virtual volumes for each vm on a libvirt/kvm host

### Parameters

 * 'virtvol'		(required, comes from virtvol_hash hiera hash, usually set as short hostname for vm and .img - hostname1.img)
 * 'virtpool'		(required, default is 'default', can be overridden in virtvol_hash)
  $volcapacity		(required, default is '60G', can be overridden in virtvol_hash)
  $volformat		(required, default is 'qcow2', can be overridden in virtvol_hash)

## Sample hiera yaml for VM host

```---
classes:
  - kvm
kvm::servertype:						'kvm'
kvm::virtnet::virtnet_name:				'br0'
kvm::virtnet::virtnet_forwardmode:		'bridge'
kvm::virtnet::virtbridge_name:			'br0'
kvm::virtnet::virtnet_macaddress:		'52:54:00:a1:a1:a1'
kvm::virtpool_hash:
  default:
    virtpool_target:					'/var/lib/libvirt/images'
  iso-images:
    virtpool_target:					'/var/lib/libvirt/iso-images'
    virtpool_format:					'iso'
kvm::virtvol_hash:
  vm1.img:
    volcapacity:						'60G'
    volformat:							'qcow2'
  vm2.img:
    volcapacity:						'60G'
    volformat:							'qcow2'
  vm3.img:
    volcapacity:						'60G'
    volformat:							'qcow2'
kvm::virts_hash:
  vm1:
    desc:								'vm1.libvirttestlab.org'
    virtmac:							'52:54:00:a2:a2:a2'
  vm2:
    desc:								'vm2.libvirttestlab.org'
    virtmac:							'52:54:00:a3:a3:a3'
  vm3:
    desc:								'vm2.libvirttestlab.org'
    virtmac:							'52:54:00:a4:a4:a4'
```

## Sample hiera yaml for webvirtmgr server

```---
classes:
  - kvm
kvm::servertype:						'kvmwebmgr'
```
