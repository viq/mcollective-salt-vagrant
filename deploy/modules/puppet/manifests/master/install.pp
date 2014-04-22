class puppet::master::install {
	package{'puppet-server':
        ensure => '3.1.0-1.el6'
    }
}
