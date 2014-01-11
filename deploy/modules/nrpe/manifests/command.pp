define nrpe::command (
  $command,
  $ensure = present,
  $libdir = $nrpe::params::libdir,
) {

 file { "${nrpe::params::nrpe_include_dir}/${title}.cfg":
    ensure  => $ensure,
    content => template('nrpe/command.cfg.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
    require => File['nrpe_include_dir'],
    notify  => Service['nrpe_service'],
  }

}
