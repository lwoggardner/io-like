class SpecGuard
  alias :implementation_orig :implementation?
  def implementation?(*args)
    args.any? { |name| name == :io_like } || implementation_orig(*args)
  end

  def standard?
   implementation?(:ruby) && !implementation?(:io_like)
  end
end
