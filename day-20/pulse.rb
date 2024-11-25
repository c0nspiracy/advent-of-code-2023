# frozen_string_literal: true

class Pulse
  attr_reader :from

  def initialize(from:)
    @from = from
  end

  def repeat!(from:)
    self.class.new(from:)
  end
end
