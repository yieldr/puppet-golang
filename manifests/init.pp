# == Class: golang
#
# Installs the go language allowing you to
# execute and compile go.
#
# === Examples
#
#  class { "golang":}
#
# === Authors
#
# Darren Coxall <darren@darrencoxall.com>
# Alex Kalyvitis <alex.kalyvitis@yieldr.com>
#
class golang (
  $version      = "1.1.2",
  $workspace    = "/vagrant",
  $arch         = "linux-amd64",
  $download_dir = "/usr/local/src",
  $download_url = undef,
) {

  if ($download_url) {
    $download_location = $download_url
  } else {
    $download_location = "http://golang.org/dl/go$version.$arch.tar.gz"
  }

  Exec {
    path => "/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin",
  }

  package { ["curl", "mercurial"]: }

  exec { "download":
    command => "curl -o $download_dir/go-$version.tar.gz $download_location",
    creates => "$download_dir/go-$version.tar.gz",
    unless  => "which go && go version | grep '$version'",
    require => Package["curl"],
  } ->
  exec { "unarchive":
    command => "tar -C /usr/local -xzf $download_dir/go-$version.tar.gz && rm $download_dir/go-$version.tar.gz",
    onlyif  => "test -f $download_dir/go-$version.tar.gz",
  }

  exec { "remove-previous":
    command => "rm -r /usr/local/go",
    onlyif  => [
      "test -d /usr/local/go",
      "which go && test `go version | cut -d' ' -f 3` != 'go$version'",
    ],
    before  => Exec["unarchive"],
  }

  file { "/etc/profile.d/golang.sh":
    content => template("golang/golang.sh.erb"),
    owner   => root,
    group   => root,
    mode    => "a+x",
  }

  file { $workspace:
    ensure => "directory",
    owner  => vagrant,
    group  => vagrant,
    mode   => "a+x",
  }

}
