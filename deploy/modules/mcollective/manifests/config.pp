class mcollective::config {
   file{"/etc/mcollective/server.cfg":
      owner => root,
      group => root,
      mode  => 0500,
      content => template("mcollective/server.cfg.erb")
   }

   file{"/etc/mcollective/client.cfg":
      owner => root,
      group => root,
      mode  => 0444,
      content => template("mcollective/client.cfg.erb")
   }

   file{"/etc/mcollective/inventory.mc":
      owner => root,
      group => root,
      mode  => 0444,
      source => "puppet:///modules/mcollective/inventory.mc"
   }

   file{"/usr/libexec/mcollective/mcollective":
      owner => root,
      group => root,
      mode  => 0444,
      recurse => true,
      source => "puppet:///modules/mcollective/lib"
   }

   file{"/etc/mcollective/facts.yaml":
      content => inline_template("<%= Hash[scope.to_hash.reject { |k,v| k.to_s =~ /(uptime|timestamp|memory|free|swap)/ }.sort].to_yaml %>"),
      owner => root,
      group => root,
      mode => 0444,
   }
}
