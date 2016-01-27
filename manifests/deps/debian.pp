# == Class: nodenv::deps::debian
#
# This module manages nodenv dependencies for Debian $::osfamily.
#
class nodenv::deps::debian {
  if ! defined(Package['build-essential']) {
    package { 'build-essential': ensure => installed }
  }

  if ! defined(Package['libreadline6-dev']) {
    package { 'libreadline6-dev': ensure => installed }
  }

  if ! defined(Package['libssl-dev']) {
    package { 'libssl-dev': ensure => installed }
  }
}
