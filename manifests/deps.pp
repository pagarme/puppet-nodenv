# == Class: nodenv::deps
#
# This module manages nodenv dependencies and should *not* be called directly.
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
# === Copyright
#
# Copyright 2013 Justin Downing
#
class nodenv::deps {
  include ::git
  include ::stdlib

  case $::osfamily {
    'Debian': {
      include nodenv::deps::debian
      $group = 'adm'
    }
    'RedHat': {
      include nodenv::deps::redhat
      $group = 'wheel'
    }
    'Suse': {
      include nodenv::deps::suse
      $group = 'users'
    }
    default: {
      fail('The nodenv module currently only suports Debian, RedHat, and Suse.')
    }
  }
}
