# == Class: icinga2::feature::gelf
#
# This module configures the Icinga2 feature gelf.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the feature gelf, absent disables it. Defaults to present.
#
# [*host*]
#   GELF receiver host address. Defaults to '127.0.0.1'.
#
# [*port*]
#   GELF receiver port. Defaults to 12201.
#
# [*source*]
#   Source name for this instance. Defaults to icinga2.
#
# [*enable_send_perfdata*]
#   Enable performance data for 'CHECK RESULT' events. Defaults to false.
#
# === Authors
#
# Icinga Development Team <info@icinga.org>
#
class icinga2::feature::gelf(
  $ensure               = present,
  $host                 = '127.0.0.1',
  $port                 = '12201',
  $source               = 'icinga2',
  $enable_send_perfdata = false,
) {

  include ::icinga2::params

  $conf_dir = $::icinga2::params::conf_dir

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_ip_address($host)
  validate_integer($port)
  validate_string($source)
  validate_bool($enable_send_perfdata)

  # compose attributes
  $attrs = {
    host                 => $host,
    port                 => $port,
    source               => $source,
    enable_send_perfdata => $enable_send_perfdata,
  }

  # create object
  icinga2::object { "icinga2::object::GelfWriter::gelf":
    object_name => 'gelf',
    object_type => 'GelfWriter',
    attrs       => $attrs,
    target      => "${conf_dir}/features-available/gelf.conf",
    order       => '10',
    notify      => $ensure ? {
      'present' => Class['::icinga2::service'],
      default   => undef,
    },
  }

  # import library 'perfdata'
  concat::fragment { 'icinga2::feature::gelf':
    target  => "${conf_dir}/features-available/gelf.conf",
    content => "library \"perfdata\"\n\n",
    order   => '05',
  }

  # manage feature
  icinga2::feature { 'gelf':
    ensure => $ensure,
  }
}
