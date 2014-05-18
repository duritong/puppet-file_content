# manage a multiline content of a file
#
# can be used to append/remove the *content*
# of a file to the *path*
#
# It also handles updates of the file to be appended.
#
# This is an alternative implementation of the file_content
# type.
#
# You should rather use the native file_content type, than
# this define. It's more a left over while poc-ing things.
define file_content::manage(
  $path,
  $ensure  = 'present',
  $content = undef,
  $source  = undef,
){
  if !$content and !$source {
    fail("You either need \$content or \$source for ${name}")
  }

  require file_content::setup

  $path_safe  = regsubst($path, '/', '_', 'G')
  $name_safe        = regsubst($name, '/', '_', 'G')
  $tmp_file         = "${file_content::setup::source_files}/${targe_file_safe}_${name_safe}"
  $target_source    = "${tmp_file}.target"
  file{
    $tmp_file:
      owner  => root,
      group  => 0,
      mode   => '0440',
      notify => Exec["handle_content_update_${name}"];
    $target_source:
      source => $tmp_file,
      owner  => root,
      group  => 0,
      mode   => '0440',
      notify => Exec["manage_file_content_${name}"];
  }

  if $content {
    File[$tmp_file]{
      content => $content,
    }
  } else {
    File[$tmp_file]{
      source => $source,
    }
  }

  if $ensure == 'present' {
    # remove the old content from the file, before introducing the new one
    exec{"handle_content_update_${name}":
      command     => "${file_content::setup::bin} absent ${path} ${target_source}",
      refreshonly => true,
      onlyif      => "test -f ${target_source}",
      before      => File[$target_source],
      subscribe   => File[$tmp_file],
    }
  }

  exec{"manage_file_content_${name}":
    command => "${file_content::setup::bin} ${ensure} ${path} ${target_source}",
    unless  => "${file_content::setup::bin} check ${path} ${target_source}",
  }
}
