# frozen_string_literal: true

class Node
  attr_reader :next

  def initialize(rules)
    @rules = rules
    @next = nil
  end

  def next=(node)
    @next = node
  end
end

class AcceptedNode
end

class RejectedNode
end
