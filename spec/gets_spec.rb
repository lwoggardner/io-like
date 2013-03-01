# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/fixtures/classes'

describe "IO::Like#gets" do

  extended_on :io_like do
    # This method of overriding sysread doesn't work for ruby itself. Would there be a way to get a fd descriptor
    # io to raise SystemCallError?
    it "reads and returns all data available before a SystemCallError is raised when the separator is nil" do

      io = IOSpecs.io_like_fixture("hello",SystemCallError,SystemCallError,"world")
      io.gets(nil).should == "hello"
      lambda { io.gets(nil) }.should raise_error(SystemCallError)
      io.gets(nil).should == "world"
    end
  end

end
