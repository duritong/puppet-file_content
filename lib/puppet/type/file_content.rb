Puppet::Type.newtype(:file_content) do

  desc <<-EOT
    Ensures that a given content of a file is contained within a file.
    The implementation matches the full content, including newlines at the
    beginning and end.  If the file content is not contained in the given file,
    Puppet will add the line to ensure the desired state.  Multiple resources
    may be declared to manage multiple parts in the same file.

    Example:

        file_content { 'some_content':
          path    => '/some/path',
          source  => '/some/source/path',
        }
        file_content { 'some_other_content':
          path    => '/some/path',
          content => "line 1\nline2",
        }

    In this example, Puppet will ensure both of the specified contents are
    contained in the file /some/path.

  EOT

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:content) do
    desc 'The content to be appended to the file located by the path parameter.'
  end

  newparam(:path) do
    desc 'The file Puppet will ensure contains the contents specified by the source or target parameter.'
    validate do |value|
      unless (Puppet.features.posix? and value =~ /^\//) or (Puppet.features.microsoft_windows? and (value =~ /^.:\// or value =~ /^\/\/[^\/]+\/[^\/]+/))
        raise(Puppet::Error, "File paths must be fully qualified, not '#{value}'")
      end
    end
  end

  newparam(:source) do
    desc 'A source file for the content to be appended to the target file'
    validate do |value|
      unless (Puppet.features.posix? and value =~ /^\//) or (Puppet.features.microsoft_windows? and (value =~ /^.:\// or value =~ /^\/\/[^\/]+\/[^\/]+/))
        raise(Puppet::Error, "File paths must be fully qualified, not '#{value}'")
      end
    end
  end

  # Autorequire the file resource if it's being managed
  autorequire(:file) do
    req = [ self[:path] ]
    req << self[:source] if self[:source]
    req
  end

  validate do
    if !self[:path] || !(self[:content] || self[:source])
      raise(Puppet::Error, "Path and either content or source are required attributes")
    end
  end
end
