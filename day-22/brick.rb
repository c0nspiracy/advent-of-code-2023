# frozen_string_literal: true

require "matrix"

class Brick
  extend Comparable

  attr_accessor :name

  def initialize(name:, start_pos:, end_pos:)
    @name = name
    @start_pos = start_pos
    @end_pos = end_pos
  end

  def <=>(other)
    [z_min, z_length] <=> [other.z_min, other.z_length]
  end

  def fall
    new_start_pos = @start_pos - Vector[0, 0, 1]
    new_end_pos = @end_pos - Vector[0, 0, 1]
    self.class.new(name: @name, start_pos: new_start_pos, end_pos: new_end_pos)
  end

  def cover?(cube)
    if single_cube?
      cube == @start_pos
    else
      fixed_axes.all? { |i| cube[i].nil? || cube[i] == @start_pos[i] } && 
        moving_axis && (cube[moving_axis].nil? || range.cover?(cube[moving_axis]))
    end
  end

  def cubes
    @cubes ||= if single_cube?
                 [@start_pos]
               else
                 vec = Vector.zero(3)
                 fixed_axes.each { |i| vec[i] = @start_pos[i] }

                 range.map do |n|
                   vec2 = vec.dup
                   vec2[moving_axis] = n
                   vec2
                 end
               end
  end

  def top_cubes
    return [@start_pos] if single_cube?

    cubes.select { |cube| cube[2] == z_max }
  end

  def bottom_cubes
    return [@start_pos] if single_cube?

    cubes.select { |cube| cube[2] == z_min }
  end

  def single_cube?
    @start_pos == @end_pos
  end

  def length
    (@start_pos - @end_pos).magnitude.to_i
  end

  def falling?
    if @falling.nil?
      @falling = [@start_pos[2], @end_pos[2]].min > 1
    else
      @falling
    end
  end

  def resting!
    @falling = false
  end

  def resting?
    !falling?
  end

  def z_length
    (@end_pos - @start_pos).map(&:abs)[2] + 1
  end

  def z_max
    [@start_pos[2], @end_pos[2]].max
  end

  def z_min
    [@start_pos[2], @end_pos[2]].min
  end

  def bounds
    [@start_pos.to_a, @end_pos.to_a].transpose.map(&:minmax)
  end

  private

  def fixed_axes
    @fixed_axes ||= [0, 1, 2].select { |i| @start_pos[i] == @end_pos[i] }.first(2)
  end

  def moving_axis
    @moving_axis ||= ([0, 1, 2] - fixed_axes)[0]
  end

  def range
    a, b = [@start_pos[moving_axis], @end_pos[moving_axis]].sort
    (a..b)
  end
end
