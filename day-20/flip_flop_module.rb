# frozen_string_literal: true

require_relative "./high_pulse"
require_relative "./low_pulse"

class FlipFlopModule
  def initialize(name:)
    @name = name
    @enabled = false
  end

  def to_s
    "<FlipFlop #{@name} (#{@enabled ? 'ON' : 'OFF'})>"
  end
  alias_method :inspect, :to_s

  def original_state?
    !@enabled
  end

  def call(pulse)
    return if pulse.high?

    output = @enabled ? LowPulse.new(from: @name) : HighPulse.new(from: @name)
    @enabled = !@enabled

    output
  end
end
