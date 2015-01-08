class NameCollisionError < RuntimeError; end

class Robot
  attr_accessor :name

  def initialize(args = {})
    @@registry ||= []
    @name_generator = args[:name_generator]
  end

  def name
    return @name unless @name.nil?

    if @name_generator
      @name = @name_generator.call
    else
      @name = generate_characters + generate_numbers
    end
    raise NameCollisionError, "There was a problem generating the robot name!" unless name_valid?(@name)

    @@registry << @name
    @name
  end

  def generate_characters
    2.times.inject(''){|s| s << ('A'..'Z').to_a.sample }
  end

  def generate_numbers
    3.times.inject(''){|s| s << rand(10).to_s }
  end

  def name_valid?(robot_name)
    (robot_name =~ /[[:alpha:]]{2}[[:digit:]]{3}/) && !@@registry.include?(robot_name)
  end
end

robot = Robot.new
puts "My pet robot's name is #{robot.name}, but we usually call him sparky."

1000000.times.each do |n|
  puts " My pet robot's name is #{Robot.new.name}, but we usually call him sparky."
end
# Errors!
# generator = -> { 'AA111' }
# Robot.new(name_generator: generator)
# Robot.new(name_generator: generator)
