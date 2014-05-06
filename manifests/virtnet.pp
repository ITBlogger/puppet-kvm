class kvm::virtnet (
  $virtnet_name        = $name,
  $virtnet_forwardmode = 'bridge',
  $virtbridge_name,
  $virtnet_macaddress,
) {
  
  tag 'kvmvirtnet'
  
  file { "virtual net ${virtnet_name} definition for ${hostname}":
    ensure  => file,
    path    => "/var/opt/lib/pe-puppet/temp/${hostname}_virtnet_${virtnet_name}.xml",
    content => template('kvm/virtnet.xml.erb'),
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
  } ->  
  exec { "remove default virtual net for ${hostname}":
    command => 'virsh net-destroy default && virsh net-undefine default',
    path    => '/usr/bin',
    onlyif  => 'virsh net-list | /bin/grep default',
  } ->  
  exec { "create virtual net ${virtnet_name} for ${hostname}":
    command => "virsh net-define /var/opt/lib/pe-puppet/temp/${hostname}_virtnet_${virtnet_name}.xml && virsh net-autostart ${virtnet_name} && virsh net-start ${virtnet_name}",
    path    => '/usr/bin',
    unless  => "virsh net-list | /bin/grep ${virtnet_name}",
  }
    
}