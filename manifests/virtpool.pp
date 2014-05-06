define kvm::virtpool (
  $virtpool        = $name,
  $virtpool_target = '/var/lib/libvirt/images',
  $virtpool_type   = 'dir',
  $virtpool_format = 'raw',
) {
  
  tag 'kvmvirtpool'
  
  file { "${virtpool_target}":
    ensure => directory,
  } ->  
  exec { "create virtual pool ${virtpool} for ${hostname}":
    command => "virsh pool-define-as ${virtpool} --target ${virtpool_target} --type ${virtpool_type} --source-format ${virtpool_format} && virsh pool-autostart ${virtpool} 
    && virsh pool-start ${virtpool}",
    path    => '/usr/bin',
    unless  => "virsh pool-list | /bin/grep ${virtpool}",
  }
    
}