# frozen_string_literal: true

require "matrix"

class Beam
  attr_reader :direction, :position

  def initialize(position: Vector[0, 0], direction: Vector[0, 1])
    @position = position
    @direction = direction
  end

  def advance
    Beam.new(
      position: @position + @direction,
      direction: @direction
    )
  end

  def reflect(mirror)
    case mirror
    when "/"
      case d
      when ">"
        Beam.new(position: @position, direction: Vector[-1, 0])
      when "<"
        Beam.new(position: @position, direction: Vector[1, 0])
      when "^"
        Beam.new(position: @position, direction: Vector[0, 1])
      when "v"
        Beam.new(position: @position, direction: Vector[0, -1])
      end
    when "\\"
      case d
      when ">"
        Beam.new(position: @position, direction: Vector[1, 0])
      when "<"
        Beam.new(position: @position, direction: Vector[-1, 0])
      when "^"
        Beam.new(position: @position, direction: Vector[0, -1])
      when "v"
        Beam.new(position: @position, direction: Vector[0, 1])
      end
    end
  end

  def split(splitter)
    case splitter
    when "-"
      case d
      when ">", "<"
        self
      when "^", "v"
        [
          Beam.new(position: @position, direction: Vector[0, -1]),
          Beam.new(position: @position, direction: Vector[0, 1])
        ]
      end
    when "|"
      case d
      when ">", "<"
        [
          Beam.new(position: @position, direction: Vector[-1, 0]),
          Beam.new(position: @position, direction: Vector[1, 0])
        ]
      when "^", "v"
        self
      end
    end
  end

  def d
    case @direction
    when Vector[0, 1] then ">"
    when Vector[0, -1] then "<"
    when Vector[1, 0] then "v"
    when Vector[-1, 0] then "^"
    else
      raise "Unknown direction: #{@direction}"
    end
  end
end
