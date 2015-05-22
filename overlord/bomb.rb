
class Bomb
  attr_accessor :id, :detonation_time, :activation_code, :deactivation_code, :wires, :status

  def initialize(id, activate_code: '1234', deactivate_code: '0000', detonate_time: 120)
    @id              = id
    @detonation_time = detonate_time
    @activation_code = activate_code
    @deactivation_code = deactivate_code
    @status = 'inactive'
  end


  def self.last
    ObjectSpace.each_object(self).to_a.last
  end

  def self.find(id)
    ObjectSpace.each_object(self).to_a.select {|bomb| bomb.id == id.to_i}.last
  end

  def activate(activate_code)
    @status = 'active' if activation_code == activate_code
  end

  def deactivate(deactivate_code)
    @status = 'inactive' if deactivation_code == deactivate_code
  end

end
