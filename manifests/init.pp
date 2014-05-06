class kvm (
  $servertype          = 'kvm',
  $virtpool_hash       = undef,
  $virtvol_hash        = undef,
  $virts_hash          = undef,
  $hypervisorpass,
) {

  include kvm::fw

  if ($servertype == 'kvm') {
    
    file { '/var/opt/lib/pe-puppet/temp':
      ensure => directory,
      owner  => 'pe-puppet',
      group  => 'pe-puppet',      
    } ->    
    package { ['libvirt',
               'python-virtinst',
               'ruby-libvirt',
               'qemu-kvm',
               'qemu-kvm-tools',
               'bridge-utils',
               'virt-manager',
               'libguestfs-tools',]:
      ensure => present,
    } ->
    service { 'libvirtd':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    } ->
    file { 'virtio-net.rom':
      ensure => file,
      path   => '/usr/share/gpxe/virtio-net.rom',
      source => 'puppet:///modules/kvm/virtio-net.rom',
      mode   => 0644,
      owner  => 'root',
      group  => 'root',
    } ->
    exec { 'saslpasswd2 for dshadmin':
      command => "/bin/echo \"${hypervisorpass}\" | /usr/sbin/saslpasswd2 -p -a libvirt dshadmin",
      unless  => '/usr/sbin/sasldblistusers2 -f /etc/libvirt/passwd.db | grep -i dshadmin',
    } ->
    exec { 'run libvirt-bootstrap.sh':
      command => '/usr/bin/curl http://retspen.github.io/libvirt-bootstrap.sh | sh',
      onlyif  => '/bin/cat /etc/libvirt/libvirtd.conf | /bin/grep -i "#listen_tcp = 1"'
    }
        
    if $virtpool_hash {
      create_resources('kvm::virtpool', $virtpool_hash)
    }

    if $virtvol_hash {
      create_resources('kvm::virtvol', $virtvol_hash)
    }
    
    if $virts_hash {
      create_resources('kvm::virts', $virts_hash)
    }

    include kvm::virtnet

    Kvm::Virtpool <| tag == 'kvmvirtpool' |> -> Kvm::Virtvol <| tag == 'kvmvirtvol' |> -> Kvm::Virts <| tag == 'kvmvirts' |>

  }

  if $servertype == 'kvmwebmgr' {
    include kvm::kvmwebmgr
  }

}

