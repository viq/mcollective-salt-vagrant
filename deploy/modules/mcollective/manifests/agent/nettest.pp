class mcollective::agent::nettest (
    $version = "latest",
) {
    mcollective::plugin{"nettest":
        type    => agent,
        ensure  => $version
    }
}
