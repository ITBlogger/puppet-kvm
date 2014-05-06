define kvm::virts (
  $vmname         = $name,
  $desc,
  $pool           = 'default',
  $poolpath       = '/var/lib/libvirt/images',
  $virttype       = 'kvm',
  $virtcpus       = '1',
  $virtmem        = '1024',
#  $virtstate     = running,
  $virtostype     = 'linux',
  $virtosvariant  = 'virtio26',
  $virtprovider   = 'libvirt',
  $virtnic        = 'virtio',
  $virtnet        = 'br0',
  $virtmac        = '\"RANDOM\"',
#  $virtip,
#  $nameserver,
#  $searchdom,
  $cdrom_location = '/var/lib/libvirt/iso-images/CCELinux-6.4.1.iso',
#  $kickstart     = undef,
  $pxe            = true,
#  $onpoweroff    = 'preserv',
#  $oncrash       = 'restart',
#  $onreboot      = 'restart',
  $autoboot       = true,
  $alwayson       = true,
) {

  tag 'kvmvirts'

  $targetmem = ($virtmem * 1024)
  $virtvol = "${vmname}.img"
  
  if $autoboot == true {
    $autostart = '--autostart'
  }
  else {
    $autostart = ''
  }
  
  if $pxe == true {
    $pxeboot    = ' --pxe'
    $cdrom_boot = ''
  }
  else {
    $pxeboot    = ''
    $cdrom_boot = " --cdrom ${cdrom_location}"
  }
  
  if $virtnet == 'br0' {
    $virtbridge = "bridge=${virtnet}"
  }
  
  if $virttype == 'kvm' {
  
	  exec { "create new VM ${vmname} using virt-install":
	    command => "virt-install --name ${vmname} --ram ${virtmem} --disk vol=${pool}/${virtvol} --vcpus ${virtcpus} --description ${desc} ${cdrom_boot} --network ${virtbridge},mac=${virtmac},model=${virtnic} --graphics vnc,listen=0.0.0.0 --os-type ${virtostype} --os-variant ${virtosvariant} --virt-type ${virttype} ${autostart}${pxeboot}",
	    path    => '/usr/sbin',
	    unless  => "/usr/bin/virsh list --all | /bin/grep ${vmname}",
	  } ~>
	  exec { "set target memory of ${virtmem}MB for ${vmname}":
      command => "virsh setmem ${vmname} ${targetmem}",
      path    => '/usr/bin',
      unless  => "/usr/bin/virsh dommemstat ${vmname} | /bin/grep ${targetmem}",
      returns => [0,1],
    } 
    
    if $alwayson == true {
    
	    exec { "start VM ${vmname}":
	      command   => "/usr/bin/virsh start ${vmname}",
	      unless    => "/usr/bin/virsh list | /bin/grep ${vmname}",
	      subscribe => Exec["set target memory of ${virtmem}MB for ${vmname}"],
	    }
	    
	  }
    
  }

#  virt { "${vmname}":
#    ensure       => $virtstate,
#    desc         => $desc,
#    memory       => $virtmem,
#    cpus         => $virtcpus,
#    virt_path    => "${poolpath}/${virtvol}",
#    virt_type    => $virttype,
#    os_type      => $virtostype,
#    os_variant   => $virtosvariant,
#    provider     => $virtprovider,
#    interfaces   => $virtinterfaces,
#    ipaddr       => $virtip,
#    macaddrs     => $virtmac,
#    nameserver   => $nameserver,
#    searchdomain => $searchdom,
#    kickstart    => $kickstart,
#    pxe          => $pxe,
#    on_poweroff  => $onpoweroff,
#    on_reboot    => $onreboot,
#    on_crash     => $oncrash,
#    autoboot     => $autoboot,
#  } -> 
  
}