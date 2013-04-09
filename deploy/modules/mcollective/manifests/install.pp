class mcollective::install {
  package{["mcollective", "mcollective-client", "mcollective-common", "gnuplot", "rubygem-redis", "rubygem-formatr"]:
      ensure => latest
  }

  package{"rspec":
      provider => "gem",
      ensure   => "2.12.0"
  }

  package{"mocha":
      provider => "gem",
      ensure   => "0.10.4"
  }
}
