require 'io/like-1.8.7'

class IO
  module Like_1_9_2
    include IO::Like_1_8_7

    # call-seq:
    #   ios.bytes            -> anEnumerator
    #
    # Calls #each_byte without a block and returns the resulting
    # <code>Enumerator</code> instance.
    def bytes
      self.to_enum(:each_byte)
    end

    # call-seq:
    #   ios.close_on_exec?  -> raise NotImplementedError
    def close_on_exec?()
      raise NotImplementedError
    end

    # call-seq:
    #   ios.close_on_exec=  -> raise NotImplementedError
    def close_on_exec=(coe)
      raise NotImplementedError
    end

    # call-seq:
    #   ios.each_byte { |char| block } -> ios
    #   ios.each_byte        -> anEnumerator
    #
    # Reads each byte from the stream and calls the given block once for
    # each character, passing the byte as an argument.
    #
    # When called without a block, returns an instance of
    # <code>Enumerator</code> which will iterate over each byte
    # in the same manner.
    #
    # <b>NOTE:</b> This method ignores <code>Errno::EAGAIN</code> and
    # <code>Errno::EINTR</code> raised by #unbuffered_read.  Therefore, this
    # method always blocks.  Aside from that exception and the conversion of
    # <code>EOFError</code> results into <code>nil</code> results, this method
    # will also raise the same errors and block at the same times as
    # #unbuffered_read.
    def each_byte
      unless block_given?
        self.to_enum(:each_byte)
      else
        while (byte = getbyte)
          yield byte
        end
        self
      end
    end

    # call-seq:
    #   ios.getbyte       -> fixnum or nil
    #
    # Calls #readbyte and either returns the result or <code>nil</code> if
    # on <code>EOFError</code>.
    #
    # Raises <code>IOError</code> if #closed? returns <code>true</code>.  Raises
    # <code>IOError</code> unless #readable? returns <code>true</code>.  Raises
    # all errors raised by #unbuffered_read except for <code>EOFError</code>.
    #
    # <b>NOTE:</b> This method ignores <code>Errno::EAGAIN</code> and
    # <code>Errno::EINTR</code> raised by #unbuffered_read.  Therefore, this
    # method always blocks.  Aside from that exception and the conversion of
    # <code>EOFError</code> results into <code>nil</code> results, this method
    # will also raise the same errors and block at the same times as
    # #unbuffered_read.
    # nil at eof
    def getbyte
      readbyte()
    rescue EOFError
      nil
    end

    # call-seq:
    #   ios.puts([obj, ...]) -> nil
    #
    # Writes the given object(s), if any, to the stream using #write after
    # converting them to strings using their <code>to_s</code> methods.  Unlike
    # #print, Array instances are recursively processed.  A record separator
    # character is written after each object which does not end with the record
    # separator already.  If no objects are given, a single record separator is
    # written.
    #
    # Raises <code>IOError</code> if #closed? returns <code>true</code>.  Raises
    # <code>IOError</code> unless #writable? returns <code>true</code>.
    #
    # <b>NOTE:</b> This method ignores <code>Errno::EAGAIN</code> and
    # <code>Errno::EINTR</code> raised by #unbuffered_write.  Therefore, this
    # method always blocks if unable to immediately write
    # <code>[obj, ...]</code> completely.  Aside from that exception, this
    # method will also raise the same errors and block at the same times as
    # #unbuffered_write.
    #
    # <b>NOTE:</b> In order to be compatible with <code>IO#puts</code>, the
    # record separator is currently hardcoded to be a single newline
    # (<code>"\n"</code>) even though the documentation implies that the output
    # record separator (<code>$\\</code>) should be used.
    def puts(*args)
      # Set the output record separator such that this method is compatible with
      # IO#puts.
      ors = "\n"

      # Write only the record separator if no arguments are given.
      if args.length == 0 then
        write(ors)
        return
      end

      # Write each argument followed by the record separator.  Recursively
      # process arguments which are Array instances.
      __io_like__array_flatten(args) do |string|
        write(string.nil? ? '' : string)
        write(ors) if string.nil? || string.index(ors, -ors.length).nil?
      end
      nil
    end

    # call-seq:
    #   ios.readbyte         -> fixnum
    #
    # Returns the next 8-bit byte (0..255) from the stream.
    #
    # Raises <code>EOFError</code> when there is no more data in the stream.
    # Raises <code>IOError</code> if #closed? returns <code>true</code>.  Raises
    # <code>IOError</code> unless #readable? returns <code>true</code>.
    #
    # <b>NOTE:</b> This method ignores <code>Errno::EAGAIN</code> and
    # <code>Errno::EINTR</code> raised by #unbuffered_read.  Therefore, this
    # method always blocks.  Aside from that exception, this method will also
    # raise the same errors and block at the same times as #unbuffered_read.
    def readbyte
      __io_like__buffered_read(1).getbyte(0)
    end

    # call-seq:
    #   ios.read_nonblock(length[, buffer]) -> string or buffer
    #
    # Returns at most <i>length</i> bytes from the data stream using only the
    # internal read buffer if the buffer is not empty.
    #
    # If internal buffer is empty sets nonblocking mode via #nonblock=(true)
    # and then reads from the underlying stream
    #
    # Raises <code>Errno::EBADF</code> if nonblocking mode is not supported
    # Raises <code>EOFError</code> when there is no more data in the stream.
    # Raises <code>IOError</code> if #closed? returns <code>true</code>.
    # Raises <code>IOError</code> unless #readable? returns <code>true</code>.
    #
    # This method will raise errors directly from #buffered_read to be handled
    # by the caller. If #unbuffered_read raises <code>Errno::EAGAIN</code> or
    # <code>Errno::EWOULDBLOCK</code> the exception will be extended with
    # <code>IO::WaitReadable</code>.
    #
    def read_nonblock(*args)
      begin
        super(*args)
      rescue IO::WaitReadable
        raise
      rescue Errno::EWOULDBLOCK, Errno::EAGAIN => ex
        ex.extend(IO::WaitReadable)
        raise ex
      end
    end

    # call-seq:
    #   ios.sysread(length)  -> string
    #
    # Reads and returns up to <i>length</i> bytes directly from the data stream,
    # bypassing the internal read buffer.
    #
    # Returns <code>""</code> if <i>length</i> is <code>0</code> regardless of
    # the status of the data stream.  This is for compatibility with
    # <code>IO#sysread</code>.
    #
    # Raises <code>EOFError</code> if reading begins at the end of the stream.
    # Raises <code>IOError</code> if #closed? returns <code>true</code>.
    #
    # <b>NOTE:</b> Because this method relies on #unbuffered_read, it will also
    # raise the same errors and block at the same times as that function.
    def sysread(length, buffer = nil)
      buffer = buffer.nil? ? '' : buffer.to_str
      buffer.slice!(0..-1) unless buffer.empty?
      return buffer if length == 0

      raise IOError, 'closed stream' if closed?
      raise IOError, 'not opened for reading' unless readable?

      # Flush the internal write buffer for writable, non-duplexed objects.
      __io_like__buffered_flush if writable? && ! duplexed?

      buffer << unbuffered_read(length)
    end

    # call-seq:
    #   ios.ungetbyte(string)  -> nil
    #   ios.ungetbyte(integer) -> nil
    #
    # A string argument is forced to 'binary' encoding and then
    # passed on to #unread.
    #
    # The low byte of an integer argument is converted to a binary
    # string and passed on to #unread.
    #
    #TODO rubyspecs for ungetbyte
    def ungetbyte(string)
      raise IOError, 'closed stream' if closed?
      raise IOError, 'not opened for reading' unless readable?
      if string.respond_to?(:to_int)
        int = string.to_int & 0xFF
        __io_like__unread(int.chr(Encoding::BINARY))
      else
        __io_like__unread(string)
      end
      nil
    end

    # call-seq:
    #   ios.write_nonblock(string)    -> integer
    #
    # The argument is converted to a string with <code>to_s</code>, converted
    # to #external_encoding if not already 'binary', forced to 'binary' and then
    # written to the stream.
    #
    # As many bytes as possible are written without blocking or
    # SystemCallError from #unbuffered_write is passed directly through
    # to be handled by the caller.
    #
    # Raises <code>IOError</code> if #closed? returns <code>true</code>.  Raises
    # <code>IOError</code> unless #writable? returns <code>true</code>.
    # TODO: rubyspec to test raises <code>IO::WaitWritable</code>.
    def write_nonblock(string)
      begin
        super(string)
      rescue IO::WaitWritable
        raise
      rescue Errno::EAGAIN => ex
        ex.extend(IO::WaitWritable)
        raise ex
      end
    end

    private

    # force string to binary and insert back into the read buffer
    # TODO: Find out why #unread is not a private method for IO::Like
    def __io_like__unread(string)
      enc = string.encoding
      string.force_encoding(Encoding::BINARY)
      begin
        __io_like__internal_read_buffer.insert(0, string)
      ensure
        string.force_encoding(enc)
      end
      nil
    end

    # Returns a reference to the internal read buffer which is always
    # a binary encoded string.
    def __io_like__internal_read_buffer
      @__io_like__read_buffer ||= String.new('').force_encoding(Encoding::BINARY)
    end

    # Returns a reference to the internal write buffer which is always
    # a binary encoded string.
    def __io_like__internal_write_buffer
      @__io_like__write_buffer ||= String.new('').force_encoding(Encoding::BINARY)
    end

  end
end
# vim: ts=2 sw=2 et
