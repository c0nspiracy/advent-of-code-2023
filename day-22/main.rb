# frozen_string_literal: true

require "matrix"
require_relative "./brick"
require_relative "./display"
require_relative "./stack"

input = ARGF.readlines(chomp: true)
puts "Starting AOC 2023 Day 22 with #{input.size} lines of input"
puts

stack = Stack.from_input(input)
bricks = stack.bricks
Display.render_both(bricks)

bricks = bricks.sort_by(&:last).to_h

loop do
  bricks_moved_this_cycle = 0

  falling, not_falling = bricks.partition { _2.falling? }
  falling_brick_names = falling.map(&:first)
  checked_bricks = not_falling.map(&:first)

  falling_brick_names.each do |name|
    brick = bricks[name]
    new_brick = brick.fall

    to_check = bricks.except(name)
    #puts "Checking if moving #{name} down would collide with any of #{to_check.keys.join(", ")}"
    collisions = to_check.select do |_, other_brick|
      new_brick.cubes.any? do |cube|
      #checked_bricks.any? do |other_brick|
      # bricks.values_at(*checked_bricks).any? do |other_brick|
        other_brick.cover?(cube)
      end
    end

    if collisions.empty?
      #puts "Moving brick #{name} down"
      bricks_moved_this_cycle += 1
      #new_brick.name = name
      bricks[name] = new_brick
    else
      #puts "Can't move brick #{name} down, it would collide with another brick"
      if collisions.values.any?(&:resting?)
        brick.resting!
      end
    end
    checked_bricks << name
  end

  puts "Moved #{bricks_moved_this_cycle} bricks down."

  break if bricks_moved_this_cycle.zero?
end
puts

Display.render_both(bricks)

supporting = Hash.new { |h, k| h[k] = Set.new }
supported_by = Hash.new { |h, k| h[k] = Set.new }

bricks.each do |name, brick|
  other_bricks = bricks.except(name)
  supported_bricks = other_bricks.select do |_, other_brick| 
    brick.top_cubes.any? do |cube|
      other_brick.bottom_cubes.any? do |other_cube|
        cube[2] == (other_cube[2] - 1) && cube[0] == other_cube[0] && cube[1] == other_cube[1]
      end
    end
  end.keys

  supporting[name].merge(supported_bricks)
  supported_bricks.each do |b|
    supported_by[b] << name
  end
end

bricks.keys.each do |name|
  s = supporting[name]
  if s.empty?
    puts "Brick #{name} isn't supporting any bricks."
  else
    puts "Brick #{name} supports bricks #{s.join(', ')}."
  end
end

part_1 = bricks.keys.count do |name|
  supporting[name].all? { |n| supported_by[n].size > 1 }
end

part_2 = bricks.keys.sum do |name|
  q = [supporting[name].to_a]
  would_fall = Set.new
  would_fall << name
  bricks_would_fall = 0
  loop do
    break if q.empty?

    falling_bricks = q.shift

    is_unsupported = falling_bricks.all? { |b| (supported_by[b] - would_fall).empty? }
    break unless is_unsupported

    bricks_would_fall += falling_bricks.size
    would_fall.merge(falling_bricks)

    res = falling_bricks.map { |fb| supporting[fb] }.reduce(:merge)
    break if res.nil? || res.empty?
    q << res.to_a
  end

  puts "Disintegrating brick #{name} would cause #{bricks_would_fall} (#{would_fall.size - 1}) other bricks to fall." unless bricks_would_fall.zero?
  bricks_would_fall
end

puts "Part 1: #{part_1}"

wrong_values_for_part_2 = [6670]
if wrong_values_for_part_2.include?(part_2)
  puts "Part 2: #{part_2} (WRONG!)"
else
  puts "Part 2: #{part_2}"
end
