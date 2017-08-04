class Build

  attr_reader :name, :generators

  def initialize(name, generators)
    @name = name
    @generators = generators
  end

end
