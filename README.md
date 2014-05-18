file_content
============

[![Build Status](https://travis-ci.org/duritong/puppet-file_content.png?branch=master)](https://travis-ci.org/duritong/puppet-file_content)

This is the file_content module to append/remove content of files to another
file.

While file_line perfectly addresses managing lines within a file, it cannot
handle parts of a file that go over a single line.

The concat module is another module, that can be used to build a file based on
multiple snippets. However the concat module always manages the whole target
file, and can not manage only subparts of a file.

This module addresses exactly these very few gaps of the other resource types,
where they don't provide a sufficient solution.

It should really be seen as an alternative to concat and file_line if you want
to manage multiple lines at once and still don't want to manage the complete
file. So it is really only useful for a very tiny part of usecases.

Usage
-----

    file_content{'some_content':
      path    => '/tmp/testfile',
      content => "first line\second line",
    }

You can also use another file as being the source for the content:

    file_content{'some_content_from_file':
      path   => '/tmp/testfile',
      source => '/tmp/source_file',
    }

You can also remove parts of that file:

    file_content{'some_content_that_should_be_removed':
      ensure  => 'absent',
      path    => '/tmp/testfile',
      content => "first line\second line",
    }

Alternative implementation
--------------------------

This module ships with an alternative implementaiton that is being implemented
by the `file_content::manage` define. This is a left-over of poc-ing the idea
and should not be used. The native type is what you should go for. I left it
for pure study and as a reference.


Support
-------

Please log tickets and issues on [github](https://github.com/duritong/puppet-file_content)
