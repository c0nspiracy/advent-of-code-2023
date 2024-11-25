# frozen_string_literal: true

require "matrix"

class Hailstone
  attr_reader :position, :velocity

  def initialize(position:, velocity:)
    @position = position
    @velocity = velocity
  end

  def to_s
    "#{@position.to_a.join(', ')} @ #{@velocity.to_a.join(', ')}"
  end
end

def parse_vector(vector_string)
  Vector[*vector_string.split(", ").map(&:to_i)]
end

input = ARGF.readlines(chomp: true)
hailstones = input.map do |line|
  position_string, velocity_string = line.split(" @ ")
  position = parse_vector(position_string)
  velocity = parse_vector(velocity_string)

  Hailstone.new(position:, velocity:)
end

hailstones.combination(2).each do |hailstone_a, hailstone_b|
  puts "Hailstone A: #{hailstone_a}"
  puts "Hailstone B: #{hailstone_b}"
  puts
end
