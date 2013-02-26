class mcollective::agent::puppet (
    $version    = latest,
    $command    = "puppet agent",
    $splaylimit = 30,
    $splay      = true
) {
    mcollective::plugin{"puppet":
        type    => agent,
        ensure  => $version,
        config  => {"command"    => $command,
                    "splaylimit" => $splaylimit,
                    "splay"      => $splay}
    }
}

