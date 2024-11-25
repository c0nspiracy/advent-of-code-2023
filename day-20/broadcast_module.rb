# frozen_string_literal: true

class BroadcastModule
  def initialize
    @name = "broadcast"
  end

  def to_s
    "<Broadcast>"
  end
  alias_method :inspect, :to_s

  def original_state?
    true
  end

  def call(pulse)
    pulse.repeat!(from: @name)
  end
end
