# frozen_string_literal: true

input = ARGF.readlines(chomp: true)
patterns = input.map(&:chars).chunk { _1.empty? ? :_separator : true }.map(&:last)

def find_reflection_lines(pattern)
  pattern.each_cons(2).with_index.select do |(left, right), n|
    left == right
  end.map(&:last)
end

def find_reflection(pattern)
  max_x = pattern.length - 1
  find_reflection_lines(pattern).each do |x|
    width = [x + 1, max_x - x].min
    left = pattern.slice(x + 1 - width, width)
    right = pattern.slice(x + 1, width)

    return x + 1 if left == right.reverse
  end

  false
end

def find_smudge(left, right)
  differences = []

  left.zip(right.reverse).each_with_index do |(a, b), y|
    a.zip(b).each_with_index do |(c, d), x|
      differences << [y, x] unless c == d
      return false if differences.size > 1
    end
  end

  differences.size == 1 ? differences.first : false
end

def find_differences(pattern)
  max_x = pattern.length - 1
  (0...max_x).each do |x|
    width = [x + 1, max_x - x].min
    left = pattern.slice(x + 1 - width, width)
    right = pattern.slice(x + 1, width)

    return x + 1 if find_smudge(left, right)
  end

  false
end

part_1 = patterns.sum do |pattern|
  if (horz = find_reflection(pattern))
    puts "Found horizontal reflection at #{horz}"
    100 * horz
  elsif (vert = find_reflection(pattern.transpose))
    puts "Found vertical reflection at #{vert}"
    vert
  else
    raise "Couldn't find the reflection"
  end
end

puts "Part 1: #{part_1}"

part_2 = patterns.sum do |pattern|
  if (horz = find_differences(pattern))
    puts "Found horizontal reflection at #{horz}"
    100 * horz
  elsif (vert = find_differences(pattern.transpose))
    puts "Found vertical reflection at #{vert}"
    vert
  else
    raise "Couldn't find the reflection"
  end
end

puts "Part 2: #{part_2}"
