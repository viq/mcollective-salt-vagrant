class mcollective::agent::filemgr (
    $version =        "latest"
) {
    mcollective::plugin{"filemgr":
        type    => agent,
        ensure  => $version
    }
}
