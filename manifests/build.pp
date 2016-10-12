# == Define: nodenv::build
#
# Calling this define will install Node in your default nodenv
# installs directory. Additionally, it can define the installed
# node as the global interpretter. It will install the bundler gem.
#
# === Variables
#
# [$install_dir]
#   This is set when you declare the nodenv class. There is no
#   need to overrite it when calling the nodenv::build define.
#   Default: $nodenv::install_dir
#   This variable is required.
#
# [$owner]
#   This is set when you declare the nodenv class. There is no
#   need to overrite it when calling the nodenv::build define.
#   Default: $nodenv::owner
#   This variable is required.
#
# [$group]
#   This is set when you declare the nodenv class. There is no
#   need to overrite it when calling the nodenv::build define.
#   Default: $nodenv::group
#   This variable is required.
#
# [$global]
#   This is used to set the node to be the global interpreter.
#   Default: false
#   This variable is optional.
#
# [%keep]
#   This is used to keep the source code of a compiled node.
#   Default: false
#   This variable is optional.
#
# [$env]
#   This is used to set environment variables when compiling node.
#   Default: []
#   This variable is optional.
#
# === Examples
#
# nodenv::build { '2.0.0-p247': global => true }
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
define nodenv::build (
  $install_dir = $nodenv::install_dir,
  $owner       = $nodenv::owner,
  $group       = $nodenv::group,
  $global      = false,
  $keep        = false,
  $env         = [],
  $patch       = undef,
) {
  include nodenv

  validate_bool($global)
  validate_bool($keep)
  validate_array($env)
  $environment_for_build = concat(["NODENV_ROOT=${install_dir}"], $env)

  if $patch {
    # Currently only accepts a single file that can be written to the local disk
    if $patch =~ /^((puppet|file):\/\/\/.*)/ {
      # Usually defaults to /var/lib/puppet
      $patch_dir = "${::settings::vardir}/nodenv"
      $patch_file = "${patch_dir}/${title}.patch"

      File {
        owner => 'root',
        group => 'root',
        mode  => '0644',
      }

      file { $patch_dir:
        ensure  => directory,
        recurse => true,
        before  => File[$patch_file],
      }->
      file { $patch_file:
        ensure => file,
        source => $patch,
      }
    }
    else {
      fail('Patch source invalid. Must be puppet:/// or file:///')
    }
  }

  Exec {
    cwd     => $install_dir,
    path    => [
      '/bin/',
      '/sbin/',
      '/usr/bin/',
      '/usr/sbin/',
      "${install_dir}/bin/",
      "${install_dir}/shims/"
    ],
    timeout => 1800,
  }

  $install_options = join([ $keep ? { true => ' --keep', default => '' },
                            # patch is a string so we must invert the
                            # logic to use the selector
                            $patch ? { undef => '', false => '', default => ' --patch' } ], '')

  exec { "own-plugins-${title}":
    command => "chown -R ${owner}:${group} ${install_dir}/plugins",
    user    => 'root',
    unless  => "test -d ${install_dir}/versions/${title}",
    require => Class['nodenv'],
  }->
  exec { "git-pull-nodebuild-${title}":
    command => 'git reset --hard HEAD && git pull',
    cwd     => "${install_dir}/plugins/node-build",
    user    => 'root',
    unless  => "test -d ${install_dir}/versions/${title}",
    require => Nodenv::Plugin['nodenv/node-build'],
  }->
  exec { "nodenv-install-${title}":
    # patch file must be read from stdin only if supplied
    command     => sprintf("nodenv install ${title}${install_options}%s", $patch ? { undef    => '',
 false    => '',
 default  => " < ${patch_file}" }),
    environment => $environment_for_build,
    creates     => "${install_dir}/versions/${title}",
  }~>
  exec { "nodenv-ownit-${title}":
    command     => "chown -R ${owner}:${group} \
                    ${install_dir}/versions/${title} && \
                    chmod -R g+w ${install_dir}/versions/${title}",
    user        => 'root',
    refreshonly => true,
  }

  if $global == true {
    exec { "nodenv-global-${title}":
      command     => "nodenv global ${title}",
      environment => ["NODENV_ROOT=${install_dir}"],
      require     => Exec["nodenv-install-${title}"],
      subscribe   => Exec["nodenv-ownit-${title}"],
      refreshonly => true,
    }
  }

}
