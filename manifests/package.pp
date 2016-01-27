# == Define: nodenv::package
#
# Calling this define will install a node package for a specific node version
#
# === Variable
#
# [$install_dir]
#   This is set when you declare the nodenv class. There is no
#   need to overrite it when calling the nodenv::package define.
#   Default: $nodenv::install_dir
#   This variable is required.
#
# [$package]
#   The name of the package to be installed. Useful if you are going
#   to install the same package under multiple node versions.
#   Default: $title
#   This variable is optional.
#
# [$version]
#   The version of the package to be installed.
#   Default: '>= 0'
#   This variable is optional.
#
# [$node_version]
#   The node version under which the package will be installed.
#   Default: undefined
#   This variable is required.

# [$timeout]
#   Seconds that a package has to finish installing. Set to 0 for unlimited.
#   Default: 300
#   This variable is optional.
#
# === Examples
#
# nodenv::package { 'thor': node_version => '2.0.0-p247' }
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
define nodenv::package(
  $install_dir  = $nodenv::install_dir,
  $package      = $title,
  $version      = 'latest',
  $node_version = undef,
  $timeout      = 300,
) {
  include nodenv

  if $node_version == undef {
    fail('You must declare a node_version for nodenv::package')
  }

  exec { "package-install-${package}-${node_version}":
    command => "npm install -g ${package}@${version}",
    unless  => "npm ls -g ${package}@${version}",
    path    => [
      "${install_dir}/versions/${node_version}/bin/",
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin'
    ],
    timeout => $timeout
  }~>
  exec { "nodenv-rehash-${package}-${node_version}":
    command     => "${install_dir}/bin/nodenv rehash",
    refreshonly => true,
    environment => [ "NODENV_ROOT=${install_dir}" ],
  }~>
  exec { "nodenv-permissions-${package}-${node_version}":
    command     => "/bin/chown -R ${nodenv::owner}:${nodenv::group} \
                  ${install_dir}/versions/${node_version}/lib/node_modules/${package} && \
                  /bin/chmod -R g+w \
                  ${install_dir}/versions/${node_version}/lib/node_modules/${package}",
    refreshonly => true,
  }

  Exec { require => Exec["nodenv-install-${node_version}"] }
}
