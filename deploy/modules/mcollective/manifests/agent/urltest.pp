class mcollective::agent::urltest (
    $version = "latest",
    $syslocation  = "Please set plugin.urltest.syslocation"
) {
    mcollective::plugin{"urltest":
        type    => agent,
        ensure  => $version,
        config  => {"syslocation" => $syslocation}
    }
}
