define mcollective::plugin_config(
    $target  = "/etc/mcollective/plugin.d",
    $owner   = "root",
    $group   = "root",
    $mode    = 0644,
    $ensure  = "present",
    $options = {}
) {
    # TODO: support concating into a server/client.cfg file
    # TODO: support ensure

    if $target =~ /plugin.d$/ {
        $content = template("mcollective/plugin_config.erb")

        file{"/etc/mcollective/plugin.d/${name}.cfg":
            owner    => $owner,
            group    => $group,
            mode     => $mode,
            content  => $content,
            require  => Class["mcollective::install"],
            notify   => Class["mcollective::service"]
        }
    }
}
