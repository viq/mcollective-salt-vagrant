class mcollective::agent::service (
    $version          = latest,
    $provider         = "puppet",
    $provider_options = {"puppet.hasstatus"  => true,
                         "puppet.hasrestart" => true}
) {
    mcollective::plugin{"service":
        type    => agent,
        ensure  => $version,
        config  => merge({"provider" => $provider}, $provider_options)
    }
}

