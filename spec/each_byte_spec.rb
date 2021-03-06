# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/fixtures/classes'

describe "IO::Like#each_byte" do
  it "raises IOError on closed stream" do
    # each_byte must have a block in order to raise the Error.
    # MRI 1.8.7 returns enumerator if block is not provided.
    # See [ruby-core:16557].
    lambda { IOSpecs.closed_file.each_byte {} }.should raise_error(IOError)
  end

  it "yields each byte" do
    File.open(IOSpecs.gets_fixtures) do |io|
      ReadableIOWrapper.open(io) do |iowrapper|
        bytes = []

        iowrapper.each_byte do |byte|
          bytes << byte
          break if bytes.length >= 5
        end

        bytes.should == [86, 111, 105, 99, 105]
      end
    end
  end

  it "works on empty streams" do
    filename = tmp("IO_Like__each_byte_test")
    File.open(filename, "w+") do |io|
      IOWrapper.open(io) do |iowrapper|
        lambda do
          iowrapper.each_byte { |b| raise IOError }
        end.should_not raise_error
      end
    end
    File.unlink(filename) if File.exist?(filename)
  end

  ruby_version_is "" ... "1.8.7" do
    it "yields a LocalJumpError when passed no block" do
      File.open(IOSpecs.gets_fixtures) do |io|
        ReadableIOWrapper.open(io) do |iowrapper|
          lambda { iowrapper.each_byte }.should raise_error(LocalJumpError)
        end
      end
    end
  end

  ruby_version_is "1.8.7" do
    it "returns an Enumerator when passed no block" do
      File.open(IOSpecs.gets_fixtures) do |io|
        ReadableIOWrapper.open(io) do |iowrapper|
          enum = iowrapper.each_byte
          enum.instance_of?(enumerator_class).should be_true
          enum.each.first(10).should == [
            86, 111, 105, 99, 105, 32, 108, 97, 32, 108
          ]
        end
      end
    end
  end
end
