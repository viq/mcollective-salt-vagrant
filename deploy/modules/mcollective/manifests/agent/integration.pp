class mcollective::agent::integration (
    $version =        "latest"
) {
    mcollective::plugin{"integration":
        type    => agent,
        ensure  => $version,
        client  => false
    }
}
