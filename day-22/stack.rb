# frozen_string_literal: true

require "matrix"
require_relative "./brick"

class Stack
  attr_reader :bricks

  def initialize(bricks:)
    @bricks = bricks
  end

  def self.from_input(input)
    names = Enumerator.produce("A", &:succ)

    bricks = input.each_with_object({}) do |line, memo|
      pieces = line.split("~")

      start_pos, end_pos = pieces.map do |piece|
        Vector[*piece.split(",").map(&:to_i)]
      end

      name = names.next
      brick = Brick.new(name:, start_pos:, end_pos:)
      memo[name] = brick
    end

    new(bricks: bricks)
  end

  def drop
  end
end
