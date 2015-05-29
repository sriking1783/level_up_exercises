
class Bomb
  attr_accessor :id, :detonation_time, :activation_code, :deactivation_code, :wires, :status, :activated_time

  def initialize(id, activate_code: '1234', deactivate_code: '0000', detonate_time: 120, wires: {red: "unsafe", green: "safe"})
    @id              = id
    @detonation_time = detonate_time
    @activation_code = activate_code
    @deactivation_code = deactivate_code
    @activated_time = nil
    @wires = wires
    @status = 'inactive'
    @failed_deactivation_attempts = 0
  end


  def self.last
    last_id = self.max_id
    ObjectSpace.each_object(self).to_a.detect{ |bomb| bomb.id == last_id }
  end

  def self.find(id)
    bomb = ObjectSpace.each_object(self).to_a.select {|bomb| bomb.id == id.to_i}.last
    bomb.status = 'explode' if time_to_explode?(bomb) && bomb.status == "active"
    bomb
  end

  def activate(activate_code)
    @activated_time = Time.now
    @status = 'active' if activation_code == activate_code
  end

  def diffuse(color)
    @status = 'inactive' if wires[color] == "safe"
    @status = 'explode'  if wires[color] == "unsafe"
  end

  def explode
    @status = 'explode'
  end

  def deactivate(deactivate_code)
    if deactivation_code == deactivate_code
      @status = 'inactive'
      @failed_deactivation_attempts = 0
    elsif @failed_deactivation_attempts ==2
      @status = 'explode'
    else
      @failed_deactivation_attempts += 1
    end
  end

  private

  def self.max_id
    ObjectSpace.each_object(self).to_a.map(&:id).max
  end

  def active?
    self.status == "active"
  end

  def self.time_to_explode?(bomb)
    !(bomb.activated_time.nil?) &&
      (Time.now >= bomb.activated_time + bomb.detonation_time)
  end
end
