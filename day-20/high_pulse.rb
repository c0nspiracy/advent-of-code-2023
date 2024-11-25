# frozen_string_literal: true

require_relative "./pulse"

class HighPulse < Pulse
  def high?
    true
  end

  def low?
    false
  end
end
