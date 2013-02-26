define mcollective::plugin (
    $type,                  # agent, facts etc
    $server = true,         # install the server side plugins
    $client = true,         # install the client side plugins
    $ensure = present,
    $config = {},           # keys to configure
    $method = "package"     # package or a url prefix
) {
    # TODO: support file base plugin distribution
    # TODO: properly support ensure

    case $type {
        default: {
                    $client_packages = ["mcollective-${name}-client"]
                    $common_packages = ["mcollective-${name}-common"]
                    $server_packages = ["mcollective-${name}-${type}"]
                 }
    }

    Package {
        ensure => $ensure,
        require => Class["mcollective::install"],
        notify => Class["mcollective::service"]
    }

    package{$common_packages: }

    if $server {
        package{$server_packages: }
    }

    if $client {
        package{$client_packages: }
    }

    if !empty($config) {
        mcollective::plugin_config{$name:
            options => $config,
            ensure  => $ensure,
        }
    }
}
