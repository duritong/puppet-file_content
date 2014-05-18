require 'spec_helper'
require 'tempfile'

provider_class = Puppet::Type.type(:file_content).provider(:ruby)
describe provider_class do
  context "when adding" do
    let :tmpfile do
      tmp = Tempfile.new('tmp')
      path = tmp.path
      tmp.close!
      path
    end
    let :resource do
      Puppet::Type::File_content.new(
        {:name => 'foo', :path => tmpfile, :content => "bb\nc2" }
      )
    end
    let :provider do
      provider_class.new(resource)
    end

    it 'should detect if the content exists in the file' do
      File.open(tmpfile, 'w') do |fh|
        fh.write("a\nbb\nc2\nd")
      end
      provider.exists?.should be_true
    end
    it 'should detect if the content does not exist in the file' do
      File.open(tmpfile, 'w') do |fh|
        fh.write("a\nbb\nc1\nd")
      end
      provider.exists?.should be_false
    end
    it 'should append to an existing file when creating and include a newline' do
      provider.create
      File.read(tmpfile).should == "bb\nc2\n"
    end
    it 'should append with a new content to an existing file when creating and not starting with a new line' do
      File.open(tmpfile, 'w') do |fh|
        fh.write("a\nbb\nc1\nd")
      end
      provider.create
      File.read(tmpfile).should == "a\nbb\nc1\nd\nbb\nc2\n"
    end
  end

  context "when removing" do
    before :each do
      # TODO: these should be ported over to use the PuppetLabs spec_helper
      #  file fixtures once the following pull request has been merged:
      # https://github.com/puppetlabs/puppetlabs-stdlib/pull/73/files
      tmp = Tempfile.new('tmp')
      @tmpfile = tmp.path
      tmp.close!
      @resource = Puppet::Type::File_content.new(
        {:name => 'foo', :path => @tmpfile, :content => "bb\nc2", :ensure => 'absent' }
      )
      @provider = provider_class.new(@resource)
    end
    it 'should remove the content if it exists' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write("a\nbb\nc1\nd\nbb\nc2\n")
      end
      @provider.destroy
      File.read(@tmpfile).should == "a\nbb\nc1\nd\n"
    end

    it 'should remove the content without touching the last new line' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nbb\nc2\nfoo2\n")
      end
      @provider.destroy
      File.read(@tmpfile).should eql("foo1\nfoo2\n")
    end

    it 'should remove any occurence of the content' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nbb\nc2\nfoo2\nbb\nc2\nfoo")
      end
      @provider.destroy
      File.read(@tmpfile).should eql("foo1\nfoo2\nfoo")
    end
  end
end
