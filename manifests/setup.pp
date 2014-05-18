# requirements for file_content
class file_content::setup {

  $id = $::id
  $root_group = $id ? {
    root    => 0,
    default => $id
  }

  if $::file_content_basedir {
    $file_content_dir = $::file_content_basedir
  } else {
    fail ("\$file_content_basedir not defined. Try running again with pluginsync=true on the [master] section of your node's '/etc/puppet/puppet.conf'.")
  }

  $source_files = "${file_content_dir}/source_files"
  $bin          = "${file_content_dir}/bin/manage_file_content.rb"

  file{
    $bin:
      source => 'puppet:///modules/file_content/manage_file_content.rb';
      owner  => $id,
      group  => $root_group,
      mode   => '0755';
    [ $file_content_dir, "${file_content_dir}/bin", $source_files ]:
      ensure  => directory,
      purge   => true,
      force   => true,
      recurse => true,
      owner   => $id,
      group   => $root_group,
      mode    => '0750';
  }
}
