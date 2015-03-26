require 'etc'
require_relative '../lib/utils'
require_relative '../lib/distro_info'

DISTROS = ENV['DISTRIBUTIONS'].split(/ +/)
ARCHITECTURES = ENV['ARCHITECTURES'].split(/ +/)
SHOW_TASKS = !!ENV['SHOW_TASKS']

include Utils

def initialize_rakefile!
  STDOUT.sync = true
  STDERR.sync = true
  DISTROS.each do |distro|
    if !valid_distro_name?(distro)
      abort "'#{distro}' is not a valid Debian or Ubuntu distribution name. " +
        "If this is a new distribution that passenger_apt_automation doesn't " +
        "know about, please edit internal/lib/distro_info.rb."
    end
  end
  if SHOW_TASKS
    create_fake_directories
  else
    Dir.chdir("/system/internal/build")
    load_passenger
    set_constants_and_envvars
  end
end

def valid_distro_name?(name)
  UBUNTU_DISTRIBUTIONS.has_key?(name) || DEBIAN_DISTRIBUTIONS.has_key?(name)
end

def create_fake_directories
  Dir.mkdir("/passenger")
  Dir.mkdir("/work")
  Dir.mkdir("/cache")
  Dir.mkdir("/output")
end

def load_passenger
  require "/passenger/lib/phusion_passenger"
  PhusionPassenger.locate_directories
  PhusionPassenger.require_passenger_lib 'constants'
end

def set_constants_and_envvars
  ENV["PASSENGER_DIR"] = "/passenger"
  ENV["WORK_DIR"]      = "/work"
  ENV["CACHE_DIR"]     = "/cache"
  ENV["OUTPUT_DIR"]    = "/output"

  set_constant_and_envvar :MAINTAINER_NAME, "Phusion"
  set_constant_and_envvar :MAINTAINER_EMAIL, "info@phusion.nl"

  if passenger_enterprise?
    set_constant_and_envvar :PASSENGER_PACKAGE_NAME, "passenger-enterprise"
    set_constant_and_envvar :PASSENGER_DEBIAN_NAME, "passenger-enterprise"
    set_constant_and_envvar :PASSENGER_SPECDIR, "passenger_enterprise"
    enterprise_version_bonus = 1
  else
    set_constant_and_envvar :PASSENGER_PACKAGE_NAME, "passenger"
    set_constant_and_envvar :PASSENGER_DEBIAN_NAME, "passenger"
    set_constant_and_envvar :PASSENGER_SPECDIR, "passenger"
    enterprise_version_bonus = 0
  end
  set_constant_and_envvar :PASSENGER_DEBIAN_EPOCH, 1
  set_constant_and_envvar :PASSENGER_DEBIAN_VENDOR_VERSION, 1 + enterprise_version_bonus
  set_constant_and_envvar :PASSENGER_DEBIAN_HOTFIX_VERSION, 1
  set_constant_and_envvar :PASSENGER_VERSION, PhusionPassenger::VERSION_STRING
  set_constant_and_envvar :PASSENGER_TARBALL, "#{PASSENGER_PACKAGE_NAME}_#{PASSENGER_VERSION}.orig.tar.gz"
  set_constant_and_envvar :NEXT_PASSENGER_VERSION, infer_next_passenger_version(PASSENGER_VERSION)

  set_constant_and_envvar :NGINX_PACKAGE_NAME, "nginx"
  set_constant_and_envvar :NGINX_DEBIAN_NAME, "nginx"
  set_constant_and_envvar :NGINX_DEBIAN_EPOCH, 1
  set_constant_and_envvar :NGINX_DEBIAN_VENDOR_VERSION, "#{8 + enterprise_version_bonus}.#{PASSENGER_VERSION}"
  set_constant_and_envvar :NGINX_DEBIAN_HOTFIX_VERSION, 1
  set_constant_and_envvar :NGINX_VERSION, PhusionPassenger::PREFERRED_NGINX_VERSION
  set_constant_and_envvar :NGINX_TARBALL, "nginx_#{NGINX_VERSION}.orig.tar.gz"
end

def set_constant_and_envvar(name, value)
  Kernel.const_set(name.to_sym, value)
  ENV[name.to_s] = value.to_s
end

def passenger_enterprise?
  defined?(PhusionPassenger::PASSENGER_IS_ENTERPRISE)
end

def infer_next_passenger_version(passenger_version)
  components = passenger_version.split(".")
  components.last.sub!(/[0-9]+$/) do |number|
    (number.to_i + 1).to_s
  end
  components.join(".")
end

# Adds the Debian epoch version to the package filename. For example,
# turns
# 
#     nginx_1.6.2-8.5.0.5~lucid1_i386.deb
# 
# into
# 
#     nginx_1:1.6.2-8.5.0.5~lucid1_i386.deb
# 
# This is because debuild does not include the epoch version number
# in the filename, but PackageCloud does. In order to make the publish
# script's yanking work correctly, we fix up the filenames using this
# function.
def maybe_add_epoch_to_filename(name)
  if name =~ /.(dsc|deb)$/
    debian_name = name.sub(/_.*/, '')
    if debian_name =~ /passenger/
      name.sub(/_/, "_#{PASSENGER_DEBIAN_EPOCH}:")
    elsif debian_name =~ /nginx/
      name.sub(/_/, "_#{NGINX_DEBIAN_EPOCH}:")
    else
      name
    end
  else
    name
  end
end