class mcollective::agent::process (
    $version = "latest",
    $fields  = "PID, COMMAND, TTY, STATE"
) {
    mcollective::plugin{"process":
        type    => agent,
        ensure  => $version,
        config  => {"fields" => $fields}
    }
}
