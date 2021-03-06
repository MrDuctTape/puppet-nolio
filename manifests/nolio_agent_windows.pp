# Class: nolio_execution
#
# Install Nolio (CA Release Automation) Execution Agent
#

define nolio::nolio_agent_windows (

  $package_version           = '5.0.2.b78',
  $package_name              = 'Release Automation Agent',
  $package_source            = "",
  $service_name              = 'nolioagent',

  $temp_dir                  = "C:\\media",
  $install_dir               = '',

  $execution_server_host,
  $agent_id                  = "${::fqdn}",
  $agent_port                = 6900,
  $execution_server_port     = 6600,
  $execution_server_secure   = false,
  $agent_mapping_application = '',
  $agent_mapping_environment = '',
  $agent_mapping_servertype  = '',
  $template_version          = "5x",

) {

  $package_ensure = 'installed'
  $service_ensure = 'running'
  $src_dir = "${temp_dir}\\puppet_nolio"
  $real_package_version = regsubst($package_version, '(\.)', '_', 'G')
  $real_package_name = "nolio_agent_windows_${real_package_version}.exe"

  Exec {
    path => "${::path}",
  }

  if ! defined(File["${temp_dir}"]) {
    file { "${temp_dir}":
      ensure => 'directory',
    }
  }
  if ! defined(File["${src_dir}"]){
    file { "${src_dir}":
      ensure  => 'directory',
      require =>File["${temp_dir}"],
    }
  }

  download_file{ "${real_package_name}":
    url                    => $package_source,
    destination_directory  => $src_dir,
  }->

  file{"${src_dir}\\agent.silent.varfile":
    content => template("nolio/agent.silent.varfile-v${template_version}.erb"),
    replace => 'yes',
  }->

  package { $package_name:
    ensure  => $package_ensure,
    source  => "${src_dir}\\${real_package_name}",
    install_options => ['-q', '-varfile', "${src_dir}\\agent.silent.varfile"],
    require => File["${src_dir}\\agent.silent.varfile"],
  }->

  service { $service_name:
    ensure  => $service_ensure,
    require => Package[$package_name],
  }
}
