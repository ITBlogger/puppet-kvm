class kvm::kvmwebmgr inherits kvm {
  
  package { ['python-pip',
             'libvirt-python',
             'libxml2-python',
             'nginx',
             'supervisor',
             'python-websockify',]:
    ensure => present,
  } ->
  package { 'django':
    ensure   => '1.5.5',
    provider => pip,
  } ->
  package { 'gunicorn':
    ensure   => '18.0',
    provider => pip,
  } ->
  package { 'lockfile':
    ensure   => latest,
    provider => pip,
  } ->
  vcsrepo { '/var/www/webvirtmgr':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/retspen/webvirtmgr.git',
    revision => '9dea5b8d21118d8369ef60c95573d11382f37fad',
  } ->
  file { '/var/www/webvirtmgr/initial_data.json':
    ensure => file,
    source => 'puppet:///modules/kvm/initial_data.json',
    owner  => nginx,
    group  => nginx,
  } ->
  file { 'webvirtmgr directory needs to be owned by nginx':
    ensure  => directory,
    path    => '/var/www/webvirtmgr',
    owner   => nginx,
    group   => nginx,
    recurse => true,
  } ->
  exec { 'initialize webvirtmgr using manage.py':
    command => '/var/www/webvirtmgr/manage.py syncdb --noinput && /bin/echo "webvirtmgrsyncdbrun" >> /var/www/webvirtmgr/syncdbstatus.txt',
    cwd     => '/var/www/webvirtmgr',
    unless  => '/bin/cat /var/www/webvirtmgr/syncdbstatus.txt | /bin/grep -i webvirtmgrsyncdbrun',
  } ~>
  exec { 'run collectstatic':
    command => '/var/www/webvirtmgr/manage.py collectstatic --noinput && /bin/echo "webvirtmgrcollectstaticrun" >> /var/www/webvirtmgr/collectstaticstatus.txt',
    unless  => '/bin/cat /var/www/webvirtmgr/collectstaticstatus.txt | /bin/grep -i webvirtmgrcollectstaticrun',
  } ~>
  file { '/etc/nginx/conf.d/webvirtmgr.conf':
    ensure  => file,
    content => template('kvm/webvirtmgr.conf.erb'),
    mode    => 0644,
    owner   => root,
    group   => root,
  } ~>
  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['nginx'],
  } ->
  file { 'supervisord.conf':
    ensure => file,
    path   => '/etc/supervisord.conf',
    source => 'puppet:///modules/kvm/supervisord.conf',
    mode   => 0644,
    owner  => root,
    group  => root,
  } ~>
  service { 'supervisord':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true, 
  } ->
  file { 'webvirtmgr-novnc startup script':
    ensure => file,
    path   => '/etc/init.d/webvirtmgr-novnc',
    source => 'puppet:///modules/kvm/webvirtmgr-novnc',
    mode   => 0755,
    owner  => root,
    group  => root,
  } ~>
  service { 'webvirtmgr-novnc':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  } #->
#  exec { 'websockify to turn on noVNC':
#    command => '/usr/bin/websockify 6080 127.0.0.1:5900 && /bin/echo "webvirtmgrwebsockifyrun" >> /var/www/webvirtmgr/websockifystatus.txt',
#    unless  => '/bin/cat /var/www/webvirtmgr/websockifystatus.txt | /bin/grep -i webvirtmgrwebsockifyrun',
#  }
  
}