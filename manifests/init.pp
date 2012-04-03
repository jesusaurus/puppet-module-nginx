class nginx(
  $ensure         = present,
  $logdir         = undef,
  $user           = $nginx::params::nginx_user,
  $passenger      = $nginx::params::nginx_passenger,
  $passenger_root = $nginx::params::nginx_passenger_root,
  $passenger_ruby = $nginx::params::nginx_passenger_ruby,
  $workers        = '1'
) inherits nginx::params {

  if !($ensure in [present, 'present', absent, 'absent']) {
    fail ("Invalid ensure value: $ensure. Must be absent or present.")
  }

  $ensure_present = $ensure in [present, 'present']

  $ensure_service = $ensure_present ? {
    true  => running,
    false => stopped,
  }

  File {
    owner => 'root',
    group => '0',
  }

  file {
    'nginx/confdir':
      path   => $nginx::params::nginx_confdir,
      ensure => directory;
    'nginx/conffile':
      ensure  => file,
      path    => "${nginx::params::nginx_confdir}/nginx.conf",
      content => template("nginx/nginx.conf.erb"),
      notify  => Service['nginx'];
    'nginx/mimetypes':
      ensure  => file,
      path    => "${nginx::params::nginx_confdir}/mime.types",
      source  => "puppet://$server/modules/nginx/mime.types",
      notify  => Service['nginx'];
    'nginx/sitesdir':
      ensure  => directory,
      path    => $nginx::params::nginx_sitesdir,
      recurse => true,
      purge   => true;
  }

  service { 'nginx':
    ensure     => $ensure_service,
    enable     => $ensure_present,
    hasstatus  => true,
    hasrestart => true,
  }

  package { 'nginx':
    ensure => $ensure,
    name   => $nginx::params::nginx_package,
  }

}
