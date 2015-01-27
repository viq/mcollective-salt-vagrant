class puppet::master::config {
	file{"/etc/puppet/manifests/site.pp":
	   source => "puppet:///modules/puppet/site.pp",
	   owner  => root,
	   group  => root,
	   mode   => 644
	}

	file{"/etc/puppet/autosign.conf":
	   source => "puppet:///modules/puppet/autosign.conf",
	   owner  => root,
	   group  => root,
	   mode   => 644
    }
}
