require 'io/like-1.8.7'

class IO
  module Like_1_9_2
    include IO::Like_1_8_7

    # call-seq:
    #   ios.binmode          -> ios
    # Sets binary mode and returns <code>self</code>.
    def binmode
      raise IOError, "closed stream" if closed?
      @external_encoding = Encoding::BINARY
      self
    end

    # call-seq:
    #   ios.binmode?        -> true or false
    # Returns true if our external encoding is binary
    def binmode?
      external_encoding == Encoding::BINARY
    end

    # call-seq:
    #   ios.bytes            -> anEnumerator
    #
    # Calls #each_byte without a block and returns the resulting
    # <code>Enumerator</code> instance.
    def bytes
      self.to_enum(:each_byte)
    end

    # call-seq:
    #   ios.chars            -> anEnumerator
    #
    # Calls #each_char without a block and returns the resulting
    # <code>Enumerator</code> instance.
    def chars
      self.to_enum(:each_char)
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
    #   ios.each_char { |char| block } -> ios
    #   ios.each_char        -> anEnumerator
    #
    # As #each_byte but yields characters (encoded strings of length 1)
    # instead of bytes
    def each_char
      unless block_given?
        self.to_enum(:each_char)
      else
        while (char = getc)
          yield char
        end
        self
      end
    end

    # call-seq:
    #   ios.each_codepoint { |char| block } -> ios
    #   ios.each_codepoint   -> anEnumerator
    #
    # As #each_char but yields codepoints instead of characters.
    def each_codepoint
      unless block_given?
        self.to_enum(:each_codepoint)
      else
        while (char = getc)
          yield  char.codepoints.next
        end
        self
      end
    end

    alias :codepoints :each_codepoint

    # call-seq:
    #   ios.each_line(sep_string = $/) { |line| block } -> ios
    #   ios.each_line(limit) { |line| block } -> ios
    #   ios.each_line(sep_string = $/,limit) { |line| block } -> ios
    #   ios.each_line(sep_string = $/) -> anEnumerator
    #   ios.each_line(limit) { |line| block } -> anEnumerator
    #   ios.each_line(sep_string = $/,limit) -> anEnumerator
    #
    # Reads each line from the stream using #gets and calls the given block once
    # for each line, passing the line as an argument. Alternatively if no block
    # is given returns an enumerator
    #
    # <b>NOTE:</b> When <i>sep_string</i> is not <code>nil</code>, this method
    # ignores <code>Errno::EAGAIN</code> and <code>Errno::EINTR</code> raised by
    # #unbuffered_read.  Therefore, this method always blocks.  Aside from that
    # exception and the conversion of <code>EOFError</code> results into
    # <code>nil</code> results, this method will also raise the same errors and
    # block at the same times as #unbuffered_read.
    def each_line(sep = :io_like, limit = :io_like)
      unless block_given?
        self.to_enum(:each)
      else
        while line = gets(sep, limit)
          yield line
        end
        self
      end
    end

    alias :each :each_line
    alias :lines :each_line

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
    #   ios.gets(sep_string = $/) { |line| block } -> ios
    #   ios.gets(limit) { |line| block } -> ios
    #   ios.gets(sep_string = $/,limit) { |line| block } -> ios
    #   ios.gets(sep_string = $/) -> anEnumerator
    #   ios.gets(limit) { |line| block } -> anEnumerator
    #   ios.gets(sep_string = $/,limit) -> anEnumerator
    #
    # Calls #readline and either returns the result or <code>nil</code> if #readline
    # raises <code>EOFError</code>.
    #
    # If #readline returns some data, <code>$.</code> is set to the value of
    # #lineno.
    #
    # <b>NOTE:</b> Due to limitations of MRI up to version 1.9.x when running
    # managed (Ruby) code, this method fails to set <code>$_</code> to the
    # returned data; however, other implementations may allow it.
    #
    def gets(sep_string = :io_like, limit = :io_like)
      # Set the last read line in the global.
      $_ = readline(sep_string, limit)
      # Set the last line number in the global.
      $. = lineno
      # Return the last read line.
      $_
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
    #   ios.readchar         -> string
    #
    # Returns the next character (encoded string of length 1) from the stream
    #
    # Raises <code>EOFError</code> when there is no more data in the stream.
    # Raises <code>IOError</code> if #closed? returns <code>true</code>.  Raises
    # <code>IOError</code> unless #readable? returns <code>true</code>.
    #
    # <b>NOTE:</b> This method ignores <code>Errno::EAGAIN</code> and
    # <code>Errno::EINTR</code> raised by #unbuffered_read.  Therefore, this
    # method always blocks.  Aside from that exception, this method will also
    # raise the same errors and block at the same times as #unbuffered_read.
    def readchar
      __io_like__buffered_read_chars(1)
    end

    # call-seq:
    #   ios.readline(sep_string = $/) { |line| block } -> ios
    #   ios.readline(limit) { |line| block } -> ios
    #   ios.readline(sep_string = $/,limit) { |line| block } -> ios
    #   ios.readline(sep_string = $/) -> anEnumerator
    #   ios.readline(limit) { |line| block } -> anEnumerator
    #   ios.readline(sep_string = $/,limit) -> anEnumerator
    #
    # Returns the next line from the stream, where lines are separated by
    # <i>sep_string</i>.  Increments #lineno by <code>1</code> for each call
    # regardless of the value of <i>sep_string</i>.
    #
    # If <i>sep_string</i> is not <code>nil</code> and not a
    # <code>String</code>, it is first converted to a <code>String</code> using
    # its <code>to_str</code> method and processing continues as follows.
    #
    # If <i>sep_string</i> is <code>nil</code>, a line is defined as the
    # remaining contents of the stream.  Partial data will be returned if a
    # low-level error of any kind is raised after some data is retrieved.  This
    # is equivalent to calling #read without any arguments except that this
    # method will raise an <code>EOFError</code> if called at the end of the
    # stream.
    #
    # If <i>sep_string</i> is an empty <code>String</code>, a paragraph is
    # returned, where a paragraph is defined as data followed by 2 or more
    # successive newline characters.  A maximum of 2 newlines are returned at
    # the end of the returned data.  Fewer may be returned if the stream ends
    # before at least 2 successive newlines are seen.
    #
    # Any other value for <i>sep_string</i> is used as a delimiter to mark the
    # end of a line.  The returned data includes this delimiter unless the
    # stream ends before the delimiter is seen.
    #
    # In any case, the end of the stream terminates the current line.
    #
    # If the <i>limit</i> argument is given, only that many bytesi, plus whatever
    # is required to complete a partial multibyte character,  will be
    # read from the underlying stream while searching for the separator. If the
    # separator is not found the partial data will be returned.
    #
    # Raises <code>EOFError</code> when there is no more data in the stream.
    # Raises <code>IOError</code> if #closed? returns <code>true</code>.  Raises
    # <code>IOError</code> unless #readable? returns <code>true</code>.
    #
    # <b>NOTE:</b> When <i>sep_string</i> is not <code>nil</code>, this method
    # ignores <code>Errno::EAGAIN</code> and <code>Errno::EINTR</code> raised by
    # #unbuffered_read.  Therefore, this method will always block in that case.
    # Aside from that exception, this method will raise the same errors and
    # block at the same times as #unbuffered_read.
    def readline(sep_string = :io_like , limit = :io_like)
      if sep_string == :io_like
        #no args
        limit = 0
        sep_string = $/
      elsif limit == :io_like
        if sep_string.nil?
          limit = 0
        elsif sep_string.respond_to?(:to_int)
          #single arg (limit)
          limit = sep_string.to_int
          sep_string = $/
        elsif sep_string.respond_to?(:to_str)
          #single arg (seperator)
          sep_string = sep_string.to_str if sep_string
          limit = 0
        else
          raise ArgumentError, "invalid args #{sep_string}, #{limit}"
        end
      else
        #two args
        limit = limit.to_int if limit
        sep_string = sep_string.to_str if sep_string
      end

      buffer = ''
      begin
        if sep_string.nil? then
          # A nil line separator means that the user wants to capture all the
          # remaining input.
          while limit <= 0 || buffer.bytesize < limit
            buffer << __io_like__buffered_read_chars(limit <= 0 ? 4096 : limit - buffer.bytesize)
          end
        else
          begin

            # Record if the user requested paragraphs rather than lines.
            paragraph_requested = sep_string.empty?
            # An empty line separator string indicates that the user wants to
            # return paragraphs.  A pair of newlines in the stream is used to
            # mark this.
            sep_string = "\n\n" if paragraph_requested

            # GG: I can't find any general guidance on how this should work in terms of searching
            # when the separator encoding (suually from source file) doesn't match
            # the default internal/external encoding. So instead we'll just do
            # a binary match.

            if paragraph_requested then
              # If the user requested paragraphs instead of lines, we need to
              # consume and discard all newlines remaining at the front of the
              # input.
              char = __io_like__buffered_read(1)
              char = __io_like__buffered_read(1) while char == "\n"
              # Put back the last character.
              __io_like__unread(char[0])
            end

            # Add each character from the input to the buffer until either the
            # buffer has the right ending or the end of the input is reached.
            while buffer.index(sep_string, -sep_string.length).nil? && (limit == 0 || buffer.bytesize < limit) do
              buffer << __io_like__buffered_read_chars(1)
            end

            if paragraph_requested then
              # If the user requested paragraphs instead of lines, we need to
              # consume and discard all newlines remaining at the front of the
              # input.
              char = __io_like__buffered_read(1)
              char = __io_like__buffered_read(1) while char == "\n"
              # Put back the last character.
              __io_like__unread(char[0])
            end

          rescue Errno::EAGAIN, Errno::EINTR
            retry if read_ready?
          end
        end
      rescue EOFError, SystemCallError
        # Reraise the error if there is nothing to return.
        raise if buffer.empty?
      end
      # Increment the number of times this method has returned a "line".
      self.lineno += 1

      buffer
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
    #   ios.set_encoding(ext_enc) -> ios
    #   ios.set_encoding("ext_enc:int_enc") -> ios
    #   ios.set_encoding(ext_enc,int_enc) -> ios
    #   ios.set_encoding("ext_enc:int_enc",opt) -> ios
    #   ios.set_encoding(ext_enc,int_enc,opt) -> ios
    #
    # Sets external and internal encodings and encoding options.
    #
    # Encodings can be specified as a single string with external and internal
    # encoding names separate by a colon, or separately as name strings or
    # <code>Encoding</code> objects.
    #
    # If the final argument is a <code>Hash</code> it will be used to specify
    # conversion options during encoding operations.
    #
    #TODO: There are no rubyspecs for the option argument
    def set_encoding(enc,arg2=:io_like, arg3=:io_like)
      if enc.respond_to?(:to_str)
        ext,int = enc.to_str.split(":", 2)
        @external_encoding = Encoding.find(ext)
        @internal_encoding = Encoding.find(int) if int && int != ext
      elsif Encoding === enc
        @external_encoding = enc
      end

      if arg2.respond_to?(:to_str)
        @internal_encoding = Encoding.find(arg2.to_str)
      elsif Encoding === arg2
        @internal_encoding = arg2 if arg2 != @external_encoding
      elsif Hash === arg2
        @encoding_options = arg2
      end

      if Hash === arg3
        @encoding_options = arg3
      end
      self
    end

    # call-seq:
    #    ios.external_encoding -> encoding
    #
    # Returns the <code>Encoding</code> object used for the external encoding.
    def external_encoding
      @external_encoding
    end

    # call-seq:
    #    ios-internal_encoding -> encoding
    #
    # Returns the <code>Encoding</code> object used for internal conversion or nil
    # if no internal conversion has been specified.
    def internal_encoding
      @internal_encoding
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
    #   ios.ungetc(string)   -> nil
    #   ios.ungetc(integer)  -> nil
    #
    # A string arguement is encoded to #external_encoding, then forced to 'binary'
    # and passed to #unread
    #
    # An integer argument is treated as a codepoint in the #internal_encoding,
    # converted to a character with #external_encoding, then forced to 'binary' and
    # passed to #unread.
    # TODO: Raise doc bug against MRI as above behaviour is undocumented (although
    # tested by rubyspec)
    #
    # Raises <code>IOError</code> if #closed? returns <code>true</code>.  Raises
    # <code>IOError</code> unless #readable? returns <code>true</code>.
    def ungetc(string)
      raise IOError, 'closed stream' if closed?
      raise IOError, 'not opened for reading' unless readable?
      if string.respond_to?(:to_int)
        #is expected to be a codepoint in the internal encoding
        chr = string.to_int.chr(__io_like__internal_encoding)
        __io_like__unread(chr.encode!(__io_like__external_encoding, __io_like__encoding_options))
      else
        __io_like__unread(string.encode(__io_like__external_encoding, __io_like__encoding_options))
      end
      nil
    end

    # call-seq:
    #   ios.write(string)    -> integer
    #
    # The argument is converted to a string with <code>to_s</code>, converted
    # to #external_encoding if not already 'binary', forced to 'binary' and then
    # written to the stream. The number of bytes written is returned.
    # TODO: rubyspec for encodings on write.
    #
    # The entire contents of <i>string</i> are written, blocking as necessary even
    # if the data stream does not block.
    #
    # Raises <code>IOError</code> if #closed? returns <code>true</code>.  Raises
    # <code>IOError</code> unless #writable? returns <code>true</code>.
    #
    # <b>NOTE:</b> This method ignores <code>Errno::EAGAIN</code> and
    # <code>Errno::EINTR</code> raised by #unbuffered_write.  Therefore, this
    # method always blocks if unable to immediately write <i>string</i>
    # completely.  Aside from that exception, this method will also raise the
    # same errors and block at the same times as #unbuffered_write.
    #
    def write(string)
      super(__io_like__write_encode(string))
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
        super(__io_like__write_encode(string))
      rescue IO::WaitWritable
        raise
      rescue Errno::EAGAIN => ex
        ex.extend(IO::WaitWritable)
        raise ex
      end
    end

    private

    # reads length bytes from the stream and converts to characters in
    # #external_encoding, ensuring that the last character is complete.
    def __io_like__buffered_read_chars(length)

      buffer = __io_like__buffered_read(length)

      buffer.force_encoding(__io_like__external_encoding)

      # read one byte at a time until the last character is valid (or EOF)
      begin
        until buffer[-1].valid_encoding?
          buffer.force_encoding(Encoding::BINARY)
          buffer << __io_like__buffered_read(1)
          buffer.force_encoding(__io_like__external_encoding)
        end
      rescue EOFError
        # return the invalid characters
      rescue SystemCallError
        # hmm, return the invalid encoded sequence, or raise the error?
        raise
      end

      # Strictly buffer might now be longer than length bytes, but we cna't return
      # a partial character and in the degenerate case where length=1, no multibyte
      # character could ever be returned.
      # MRI does not honour the length argument in these cases either
      buffer.encode!(__io_like__internal_encoding, __io_like__encoding_options)

      #TODO: Not sure why the buffer is not considered tainted when we read the whole file in at once
      buffer.taint
    end

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

    # lazy instantiation of encoding options
    def __io_like__encoding_options
      @encoding_options ||= {}
    end

    # the real external encoding to use, if not set
    def __io_like__external_encoding
      external_encoding || Encoding::default_external
    end

    # the real internal encoding to use, if not set
    def __io_like__internal_encoding
      internal_encoding || Encoding::default_internal || __io_like__external_encoding
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

    # Encode a string for writing to the stream, ie convert to #external_encoding
    # unless it is already 'binary'
    def __io_like__write_encode(string)
      string = string.to_s
      unless string.encoding == Encoding::BINARY
        string.encode(__io_like__external_encoding, __io_like__encoding_options)
      else
        string
      end
    end
  end
end
# vim: ts=2 sw=2 et
