class Build

  attr_reader :name, :generators, :applications

  def initialize(name, generators, additional_applications=[])
    @name = name
    @applications = [@name] + (additional_applications || [])
    @generators = generators
  end

end
