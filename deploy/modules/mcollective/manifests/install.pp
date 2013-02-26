class mcollective::install {
  package{["mcollective", "mcollective-client", "mcollective-common", "gnuplot", "rubygem-redis", "rubygem-formatr"]:
      ensure => latest
  }
}
