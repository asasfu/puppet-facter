class facter($purge_unmanaged_yaml_facts = false) {
  validate_bool($purge_unmanaged_yaml_facts)
  resources { 'fact':
    purge => $purge_unmanaged_yaml_facts
  }
}
