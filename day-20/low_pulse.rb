# frozen_string_literal: true

require_relative "./pulse"

class LowPulse < Pulse
  def low?
    true
  end

  def high?
    false
  end
end
