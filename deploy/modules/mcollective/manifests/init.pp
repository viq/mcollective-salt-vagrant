class mcollective {
  class{"mcollective::install": } ->
  class{"mcollective::config": } ~>
  class{"mcollective::service": } ->
  Class[$name]

  class{"mcollective::agent::package": }
  class{"mcollective::agent::service": }
  class{"mcollective::agent::puppet": }
  class{"mcollective::agent::filemgr": }
  class{"mcollective::agent::process": }
  class{"mcollective::agent::nettest": }
  class{"mcollective::agent::nrpe": conf_dir => "/etc/nrpe.d"}
  class{"mcollective::agent::urltest": syslocation => $hostname}

  Class["mcollective::install"] ~> Class["mcollective::service"]
}
