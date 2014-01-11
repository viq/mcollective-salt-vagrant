node default {
  if $::hostname =~ /^middleware/ {
     $role = "middleware"
  } else {
     $role = "node"
  }

  class{"roles::${role}": } ->

  file{"/etc/mcollective/classes.txt":
    owner => root,
    group => root,
    mode => 0444,
    content => inline_template("<%= classes.join('\n') %>")
  }

  host{"puppet":
    ip => $::middleware_ip
  }
}
