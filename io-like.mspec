# encoding: UTF-8

require 'mspec/runner/formatters'

class MSpecScript
  # An ordered list of the directories containing specs to run
  set :files, ['spec', 'rubyspec']

  # The default implementation to run the specs.
  set :target, 'ruby'

  irrelevant_class_methods = [
    "IO.copy_stream","IO.try_convert",
    "IO.for_fd", "IO.foreach", "IO.pipe", "IO.popen",
    "IO.read", "IO.new", "IO#initialize", "IO.open", "IO::SEEK", "IO.select",
     # rubyspec bug - this is actually IO.readlines, not IO#readines
    "IO#readlines when passed a string that starts with a |",
    # this actually tests mode handling for File.read
    "IO#read with 1.9 encodings strips the BOM"
  ]

  # Also instance methods related to file descriptor IO
  irrelevant_instance_methods = [
    "IO#advise","IO#close_on_exec",
    "IO#dup", "IO#ioctl", "IO#fcntl", "IO#fsync", "IO#pid", "IO#stat",
    "IO#fileno", "IO#to_i", "IO#reopen", "terminal device (TTY)"
  ]

  # and some intentionally not compliant
  non_compliant = [
    "IO#read_nonblock changes the behavior of #read to nonblocking",
    "IO#ungetc raises IOError when invoked on stream that was not yet read",
    #the very definition says to expect unpredictable results for the below
    "IO#sysread on a file reads normally even when called immediately after a buffered IO#read",
    "$_" # cannot set $_ from ruby code to we cannot comply with anything mentioning $_
  ]

  # Exclude IO specs not relevant to IO::Like
  set :excludes, irrelevant_class_methods + irrelevant_instance_methods + non_compliant

  # These are options that are passed to the ruby interpreter running the tests
  #  to test io like "-r io/like" must be passed on the command line to mspec
  set :requires, [
    "-I", File.expand_path("../lib", __FILE__),
    "-I", File.expand_path("../mspec/lib", __FILE__),
  ]

  MSpec.enable_feature :encoding if "string".respond_to?(:force_encoding)
end
