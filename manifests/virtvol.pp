define kvm::virtvol (
  $virtvol     = $name,
  $virtpool    = 'default',
  $volcapacity = '60G',
  $volformat   = 'qcow2',
) {

  tag 'kvmvirtvol'
    
  exec { "create virtual volume ${virtvol} in ${virtpool}":
    command => "virsh vol-create-as ${virtpool} ${virtvol} ${volcapacity} --format ${volformat}",
    path    => '/usr/bin',
    unless  => "virsh vol-list --pool ${virtpool} | /bin/grep ${virtvol}",
#    onlyif  => "virsh pool-list ${pool} | /bin/grep ${pool}",
  } 
  
}