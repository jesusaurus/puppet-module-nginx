define nginx::site($domain=undef,
                   $root=undef,
                   $ensure=present,
                   $owner=undef,
                   $group=undef,
                   $mediaroot="",
                   $mediaprefix="",
                   $default_vhost=false,
                   $autoindex=false,
                   $rewrite_missing_html_extension=false,
                   $upstreams=[],
                   $aliases=[],
                   $ssl=false,
                   $ssl_certificate="",
                   $ssl_certificate_key="",
                   $keepalive=5,
                   $proxy=false,
                   $proxy_ssl=false,
                   $proxy_domain=undef,
                   $proxy_port=undef,
                   $content=undef) {

  if $root != undef {

    $absolute_mediaroot = inline_template("<%= File.expand_path(mediaroot, root) %>")

    if $ensure == 'present' {
      # Parent directory of root directory. /var/www for /var/www/blog
      $root_parent = inline_template("<%= root.match(%r!(.+)/.+!)[1] %>")

      if !defined(File[$root_parent]) {
        file { $root_parent:
          ensure => directory,
          owner => $owner,
          group => $group,
        }
      }

      file { $root:
        ensure => directory,
        owner => $owner,
        group => $group,
        require => File[$root_parent],
      }

    } elsif $ensure == 'absent' {

      file { $root:
        ensure => $ensure,
        owner => $owner,
        group => $group,
        recurse => true,
        purge => true,
        force => true,
      }
    }

  }

  # This logic can't be inside the resource declaration,
  # so we need a separate resource declaration for each case.
  if $source != undef {
    file {
      "/etc/nginx/sites-available/${name}.conf":
        ensure => $ensure,
        source => $source,
        require => $root ? {
          undef   => Package[nginx],
          default => [
            File[$root],
            Package[nginx],
          ],
        },
        notify => Service[nginx];
    }
  } elsif $content != undef {
    file {
      "/etc/nginx/sites-available/${name}.conf":
        ensure => $ensure,
        content => $content,
        require => $root ? {
          undef   => Package[nginx],
          default => [
            File[$root],
            Package[nginx],
          ],
        },
        notify => Service[nginx];
    }
  } else {
    file {
      "/etc/nginx/sites-available/${name}.conf":
        ensure => $ensure,
        content => template("nginx/site.conf.erb"),
        require => $root ? {
          undef   => Package[nginx],
          default => [
            File[$root],
            Package[nginx],
          ],
        },
        notify => Service[nginx];
    }
  }

  file {
    "/etc/nginx/sites-enabled/${name}.conf":
      ensure => $ensure ? {
        'present' => link,
        'absent' => $ensure,
      },
      target => $ensure ? {
        'present' => "/etc/nginx/sites-available/${name}.conf",
        'absent' => notlink,
      },
      require => File["/etc/nginx/sites-available/${name}.conf"],
      notify => Service[nginx];
  }
}
