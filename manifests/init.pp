# == Class: nodenv
#
# This module manages nodenv on Ubuntu. The default installation directory
# allows nodenv to available for all users and applications.
#
# === Variables
#
# [$repo_path]
#   This is the git repo used to install nodenv.
#   Default: 'https://github.com/sstephenson/nodenv.git'
#   This variable is required.
#
# [$install_dir]
#   This is where nodenv will be installed to.
#   Default: '/usr/local/nodenv'
#   This variable is required.
#
# [$owner]
#   This defines who owns the nodenv install directory.
#   Default: 'root'
#   This variable is required.
#
# [$group]
#   This defines the group membership for nodenv.
#   Default: 'adm'
#   This variable is required.
#
# [$latest]
#   This defines whether the nodenv $install_dir is kept up-to-date.
#   Defaults: false
#   This vaiable is optional.
#
# === Requires
#
# This module requires the following modules:
#   'puppetlabs/git' >= 0.0.3
#   'puppetlabs/stdlib' >= 4.1.0
#
# === Examples
#
# class { nodenv: }  #Uses the default parameters
#
# class { nodenv:  #Uses a user-defined installation path
#   install_dir => '/opt/nodenv',
# }
#
# More information on using Hiera to override parameters is available here:
#   http://docs.puppetlabs.com/hiera/1/puppet.html#automatic-parameter-lookup
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
# === Copyright
#
# Copyright 2013 Justin Downing
#
class nodenv (
  $repo_path   = 'https://github.com/nodenv/nodenv.git',
  $install_dir = '/usr/local/nodenv',
  $owner       = 'root',
  $group       = $nodenv::deps::group,
  $latest      = false,
) inherits nodenv::deps {
  include nodenv::deps

  exec { 'git-clone-nodenv':
    command => "/usr/bin/git clone ${nodenv::repo_path} ${install_dir}",
    creates => $install_dir,
    cwd     => '/',
    user    => $owner,
    require => Package['git'],
  }

  file { [
    $install_dir,
    "${install_dir}/plugins",
    "${install_dir}/shims",
    "${install_dir}/versions"
  ]:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '0775',
  }

  file { '/etc/profile.d/nodenv.sh':
    ensure  => file,
    content => template('nodenv/nodenv.sh'),
    mode    => '0775'
  }

  # run `git pull` on each run if we want to keep nodenv updated
  if $nodenv::latest == true {
    exec { 'update-nodenv':
      command => '/usr/bin/git pull',
      cwd     => $install_dir,
      user    => $owner,
      require => File[$install_dir],
    }
  }

  Exec['git-clone-nodenv'] -> File[$install_dir]

}
