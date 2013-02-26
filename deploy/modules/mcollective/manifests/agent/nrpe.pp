class mcollective::agent::nrpe (
    $version  = "latest",
    $conf_dir = "/etc/nagios/nrpe.d"
) {
    mcollective::plugin{"nrpe":
        type    => agent,
        ensure  => $version,
        config  => {"conf_dir" => $conf_dir}
    }
}
