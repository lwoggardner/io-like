require 'io/like-1.9.2'
class IO
  module Like_1_9_3
    include IO::Like_1_9_2

    # call-seq:
    #   ios.advise() -> raise NotImplementedError
    #
    # Not implemented for <code>IO::Like</code>.
    def advise(*args)
      raise NotImplementedError
    end

  end
end
