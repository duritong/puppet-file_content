require 'spec_helper'
require 'tempfile'
describe Puppet::Type.type(:file_content) do
  let :file_content do
    Puppet::Type.type(:file_content).new(:name => 'foo', :content => "line1\nline2", :path => '/tmp/path')
  end
  it 'should require that either a content or source is specified' do
    expect { Puppet::Type.type(:file_content).new(:name => 'foo', :path => '/tmp/file') }.to raise_error(Puppet::Error, /Path and either content or source are required attributes/)
  end
  it 'should require that a file is specified' do
    expect { Puppet::Type.type(:file_content).new(:name => 'foo', :content => 'path') }.to raise_error(Puppet::Error, /Path and either content or source are required attributes/)
  end
  it 'should require that a file is specified with source' do
    expect { Puppet::Type.type(:file_content).new(:name => 'foo', :source => '/test/a') }.to raise_error(Puppet::Error, /Path and either content or source are required attributes/)
  end
  it 'should default to ensure => present' do
    file_content[:ensure].should eq :present
  end

  it "should autorequire the file it manages" do
    catalog = Puppet::Resource::Catalog.new
    file = Puppet::Type.type(:file).new(:name => "/tmp/path")
    catalog.add_resource file
    catalog.add_resource file_content

    relationship = file_content.autorequire.find do |rel|
      (rel.source.to_s == "File[/tmp/path]") && (rel.target.to_s == file_content.to_s)
    end
    relationship.should be_a Puppet::Relationship
  end

  it "should not autorequire the file it manages if it is not managed" do
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource file_content
    file_content.autorequire.should be_empty
  end

  context 'with content' do
    it 'should accept a content and path' do
      file_content[:content] = "line1\nline2"
      file_content[:content].should == "line1\nline2"
      file_content[:path] = '/my/path'
      file_content[:path].should == '/my/path'
    end
    it 'should accept posix filenames' do
      file_content[:path] = '/tmp/path'
      file_content[:path].should == '/tmp/path'
    end
    it 'should not accept unqualified path' do
      expect { file_content[:path] = 'file' }.to raise_error(Puppet::Error, /File paths must be fully qualified/)
    end
  end
  context 'with source' do
    let :file_content do
      Puppet::Type.type(:file_content).new(:name => 'foo', :source => "/tmp/source", :path => '/tmp/path')
    end
    it 'should accept a source and path' do
      file_content[:source] = '/tmp/source'
      file_content[:source].should == '/tmp/source'
      file_content[:path] = '/my/path'
      file_content[:path].should == '/my/path'
    end
    it 'should accept posix filenames' do
      file_content[:source] = '/tmp/path'
      file_content[:source].should == '/tmp/path'
    end
    it 'should not accept unqualified path' do
      expect { file_content[:source] = 'file' }.to raise_error(Puppet::Error, /File paths must be fully qualified/)
    end

    it "should autorequire the file it sources from" do
      catalog = Puppet::Resource::Catalog.new
      file = Puppet::Type.type(:file).new(:name => "/tmp/source")
      catalog.add_resource file
      catalog.add_resource file_content

      relationship = file_content.autorequire.find do |rel|
        (rel.source.to_s == "File[/tmp/source]") and (rel.target.to_s == file_content.to_s)
      end
      relationship.should be_a Puppet::Relationship
    end

    it "should not autorequire the file it manages if it is not managed" do
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource file_content
      file_content.autorequire.should be_empty
    end

  end

end
