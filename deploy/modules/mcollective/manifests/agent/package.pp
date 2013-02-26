class mcollective::agent::package (
    $version =        "latest",
    $yum_clean_mode = "all"
) {
    mcollective::plugin{"package":
        type    => agent,
        ensure  => $version,
        config  => {"yum_clean_mode" => $yum_clean_mode}
    }
}
