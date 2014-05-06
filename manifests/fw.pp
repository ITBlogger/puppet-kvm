class kvm::fw inherits kvm {
#
  if $servertype == 'kvmwebmgr' {
    firewall { '100 Accept new tcp 80 http connections for webvirtmgr':
      proto  => 'tcp',
      state  => 'NEW',
      dport  => '80',
      action => 'accept',
    }

    firewall { '100 Accept new tcp 6080 http connections for novnc':
      proto  => 'tcp',
      state  => 'NEW',
      dport  => '6080',
      action => 'accept',
    }

#    firewall { '100 Accept new tcp 8000 http connections for webvirtmgr':
#      proto  => 'tcp',
#      state  => 'NEW',
#      dport  => '8000',
#      action => 'accept',
#    }

  }

  if $servertype == 'kvm' {
    firewall { '100 Accept new tcp libvirt connections':
      proto  => 'tcp',
	    state  => 'NEW',
	    dport  => '16509',
	    action => 'accept',
	  }
	
	  firewall { '100 Accept new tcp vnc connections':
	    proto  => 'tcp',
	    state  => 'NEW',
	    dport  => '5900-5910',
	    action => 'accept',
	  }
	  
	  firewall { '100 Accept new udp dhcp connections':
	    proto  => 'udp',
	    state  => 'NEW',
	    dport  => '67-68',
	    action => 'accept',
	  }
	
	  firewall { '100 Accept new udp dhcp proxy connections':
	    proto  => 'udp',
	    state  => 'NEW',
	    dport  => '4011',
	    action => 'accept',
	  }

  }

}

