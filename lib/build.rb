class Build

  attr_reader :name, :applications, :generators

  def initialize(name, applications, generators)
    @name = name
    @applications = applications
    @generators = generators
  end

end
