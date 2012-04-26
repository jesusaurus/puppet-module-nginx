class nginx::params {

  case $osfamily {
    "FreeBSD": {
      $nginx_user           = 'www'
      $nginx_confdir        = '/usr/local/etc/nginx'
      $nginx_package        = 'www/nginx'
      $nginx_events         = 'kqueue'
      $nginx_passenger      = true
      $nginx_passenger_root = '/usr/local/lib/ruby/gems/1.8/gems/passenger-3.0.7'
      $nginx_passenger_ruby = '/usr/local/bin/ruby18'
    }
    default: {
      $nginx_user    = 'www-data'
      $nginx_confdir = '/etc/nginx'
      $nginx_package = 'nginx'
      $nginx_events  = 'epoll'
    }
  }

  $nginx_sitesdir = "$nginx_confdir/sites"

}
