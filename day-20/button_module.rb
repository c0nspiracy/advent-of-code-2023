# frozen_string_literal: true

class ButtonModule
  def initialize
    @name = "button"
  end

  def to_s
    "<Button>"
  end
  alias_method :inspect, :to_s

  def original_state?
    true
  end

  def call
    LowPulse.new(from: @name)
  end
end
