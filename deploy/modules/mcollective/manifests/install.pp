class mcollective::install {
  package{["mcollective", "mcollective-client", "mcollective-common",
           "gnuplot", "rubygem-redis", "rubygem-formatr", "rubygem-rake",
           "rubygem-rspec", "rubygem-mocha", "rubygem-mcollective-test"]:
      ensure => latest
  }
}
