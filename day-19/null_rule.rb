# frozen_string_literal: true

class NullRule < Rule
  def initialize(destination:)
    @destination = destination
  end

  def call(*)
    @destination
  end

  def conditional?
    false
  end

  def to_s
    "(#{@destination})"
  end
  alias_method :inspect, :to_s
end
