
class Bomb
  attr_accessor :id, :detonation_time, :activation_code, :deactivation_code, :wires, :status, :activated_time

  def initialize(id, activate_code: '1234', deactivate_code: '0000', detonate_time: 120)
    @id              = id
    @detonation_time = detonate_time
    @activation_code = activate_code
    @deactivation_code = deactivate_code
    @activated_time = nil
    @status = 'inactive'
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
    self.activated_time = Time.now
    self.status = 'active' if activation_code == activate_code
  end

  def explode
    @status = 'explode'
  end

  def deactivate(deactivate_code)
    @status = 'inactive' if deactivation_code == deactivate_code
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
