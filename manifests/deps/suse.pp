# == Class: nodenv::deps::suse
#
# This module manages nodenv dependencies for suse $::osfamily.
#
class nodenv::deps::suse {
  if ! defined(Package['binutils']) {
    package { 'binutils': ensure => installed }
  }

  if ! defined(Package['gcc']) {
    package { 'gcc': ensure => installed }
  }

  if ! defined(Package['automake']) {
    package { 'automake': ensure => installed }
  }

  if ! defined(Package['openssl-devel']) {
    package { 'openssl-devel': ensure => installed }
  }

  if ! defined(Package['readline-devel']) {
    package { 'readline-dev': ensure => installed }
  }
}
