vapi_sources = [
  'config.vapi'
]

redtip_vala_sources = [
  'app.vala',
  'main.vala',
  'window.vala',
  'service.vala',
  'service_row.vala',
  'services_list_model.vala',
  'systemd.vala',
  'utils.vala'
]

redtip_sources = [
  vapi_sources,
  redtip_vala_sources,
  resources
]

redtip_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('libhandy-1')
]

redtip_vala_args = [
  '--target-glib', '2.50',
  '--gresources', resource_files,
]

c_args = [
  '-DGETTEXT_PACKAGE="redtip"',
]

executable('redtip', redtip_sources,
  include_directories: config_h_dir,
  vala_args: redtip_vala_args,
  c_args : c_args,
  dependencies: redtip_deps,
  install: true,
)
