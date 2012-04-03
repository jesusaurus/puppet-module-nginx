define nginx::site (
  $aliases                        = [],
  $autoindex                      = false,
  $content                        = undef,
  $default_vhost                  = false,
  $domain                         = undef,
  $ensure                         = present,
  $group                          = '0',
  $keepalive                      = '5',
  $mediaprefix                    = '',
  $mediaroot                      = '',
  $owner                          = '0',
  $port                           = undef,
  $proxy                          = false,
  $proxy_domain                   = undef,
  $proxy_port                     = undef,
  $proxy_ssl                      = false,
  $rewrite_missing_html_extension = false,
  $root                           = undef,
  $source                         = undef,
  $ssl                            = false,
  $ssl_certificate                = '',
  $ssl_certificate_key            = '',
  $ssl_client                     = undef,
  $ssl_client_certificate         = undef,
  $ssl_timeout                    = '5m',
  $upstreams                      = []
) {
  include nginx
  include nginx::params

  $site_file = "${nginx::params::nginx_sitesdir}/${name}.conf"

  File {
    owner => $owner,
    group => $group,
  }

  if $source and $content {
    fail ('Both source and content supplied; please supply only one or the other')
  }

  if !($ensure in [present, 'present', absent, 'absent']) {
    fail ("Invalid ensure value: $ensure. Must be absent or present.")
  }

  if $ensure in [absent, 'absent'] {
    $config_type  = 'absent'
  } elsif $source {
    $config_type  = 'source'
    $source_line  = $source
  } elsif $content {
    $config_type  = 'content'
    $content_line = $content
  } else {
    $config_type  = 'template'
    $content_line = template('nginx/site.conf.erb')
  }

  if $root {
    case $config_type {
      'absent': {
        file { $root:
          ensure  => $ensure,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }
      default: {
        $root_parent = split($root, '/[^/]+/?$')
        if !defined(File[$root_parent]) {
          file { $root_parent:
            ensure => directory,
          }
        }
        file { $root:
          ensure => directory,
        }
      }
    }
  }

  case $config_type {
    'source': {
      file { $site_file:
        ensure  => $ensure,
        source  => $source_line,
        require => Package['nginx'],
        notify  => Service['nginx'],
      }
    }
    default: {
      file { $site_file:
        ensure  => $ensure,
        content => $content_line,
        require => Package['nginx'],
        notify  => Service['nginx'],
      }
    }
  }

}
