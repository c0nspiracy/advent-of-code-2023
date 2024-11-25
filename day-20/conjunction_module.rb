# frozen_string_literal: true

require_relative "./high_pulse"
require_relative "./low_pulse"

class ConjunctionModule
  def initialize(name:)
    @name = name
    @last_pulses = {}
  end

  def to_s
    "<Conjunction #{@name}>"
  end
  alias_method :inspect, :to_s

  def set_input(name)
    @last_pulses[name] = LowPulse.new(from: name)
  end

  def original_state?
    @last_pulses.values.all?(&:low?)
  end

  def call(pulse)
    # if @name == "gh" && pulse.high?
    #   puts "gh received a HIGH pulse from #{pulse.from}"
    # end
    @last_pulses[pulse.from] = pulse
    if @last_pulses.values.all?(&:high?)
      LowPulse.new(from: @name)
    else
      HighPulse.new(from: @name)
    end
  end
end
