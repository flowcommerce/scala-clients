class Generator

  attr_reader :key, :srcdir, :template

  def initialize(key, srcdir, opts={})
    @key = key
    @srcdir = srcdir
    @template = opts.delete(:template) || @key
  end

end
