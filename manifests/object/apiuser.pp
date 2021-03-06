# == Define: icinga2::object::apiuser
#
# Manage Icinga2 ApiUser objects.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disables it. Defaults to present.
#
# [*password*]
#   Password string.
#
# [*client_cn*]
#   Optional. Client Common Name (CN).
#
# [*permissions*]
#   Array of permissions. Either as string or dictionary with the keys permission
#   and filter. The latter must be specified as function.
#
# [*target*]
#   Destination config file to store in this object. File will be declared at the
#   first time.
#
# [*order*]
#   String to set the position in the target file, sorted alpha numeric. Defaults to 10.
#
# === Examples
#
# permissions = [ "*" ]
#
# permissions = [ "objects/query/Host", "objects/query/Service" ]
#
# permissions = [
#   {
#     permission = "objects/query/Host"
#     filter = {{ regex("^Linux", host.vars.os) }}
#   },
#   {
#     permission = "objects/query/Service"
#     filter = {{ regex("^Linux", service.vars.os) }}
#   }
# ]
#
# === Authors
#
# Icinga Development Team <info@icinga.org>
#
define icinga2::object::apiuser(
  $ensure      = present,
  $apiuser     = $title,
  $password    = undef,
  $client_cn   = undef,
  $order       = '10',
  $target,
  $permissions,
) {

  include ::icinga2::params

  $conf_dir = $::icinga2::params::conf_dir

  # validation
  validate_string($apiuser)
  validate_string($order)
  validate_absolute_path($target)
  validate_array($permissions)

  if $password { validate_string($password) }
  if $client_cn { validate_string($client_cn) }

  # compose the attributes
  $attrs = {
    password    => $password,
    client_cn   => $client_cn,
    permissions => $permissions,
  }

  # create object
  icinga2::object { "icinga2::object::ApiUser::${title}":
    ensure      => $ensure,
    object_name => $apiuser,
    object_type => 'ApiUser',
    attrs       => $attrs,
    target      => $target,
    order       => $order,
    notify      => Class['::icinga2::service'],
  }
}
