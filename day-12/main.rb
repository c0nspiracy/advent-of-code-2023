# frozen_string_literal: true

# Models a Spring Condition
class SpringCondition
  UNKNOWN = '?'
  OPERATIONAL = '.'
  DAMAGED = '#'

  def initialize(spring_list:, damaged_group_sizes:)
    @spring_list = spring_list
    @damaged_group_sizes = damaged_group_sizes
  end

  def foo
    binding.irb
  end
end

def fooos(string)
  foos(string).map do |s|
    s.split('.').reject(&:empty?).map(&:size)
  end
end

def foos(string)
  ret = [string]
  loop do
    newret = []
    ret.each do |s|
      newret.concat(foo(s))
    end
    break if ret.size == newret.size

    ret = newret
  end
  ret
end

def foo(string)
  ret = []
  idx = string.index('?')
  return [string] unless idx

  string[idx] = '.'
  ret << string.dup
  string[idx] = '#'
  ret << string.dup
  ret
end

input = ARGF.readlines(chomp: true)
part_1_total = 0
part_2_total = 0

input.each do |line|
  left, right = line.split
  damaged_group_sizes = right.split(',').map(&:to_i)
  arrangements = fooos(left).count(damaged_group_sizes)
  puts "#{left} #{damaged_group_sizes} - #{arrangements} arrangement(s)"
  part_1_total += arrangements

  left = Array.new(5, left).join('?')
  damaged_group_sizes = right.split(',').map(&:to_i) * 5
  arrangements = fooos(left).count(damaged_group_sizes)
  puts "#{left} #{damaged_group_sizes} - #{arrangements} arrangement(s)"
  part_2_total += arrangements
end

puts "Part 1: #{part_1_total}"
puts "Part 1: #{part_2_total}"
