# frozen_string_literal: true

def hash(string)
  string.chars.reduce(0) do |value, char|
    value += char.ord
    value *= 17
    value % 256
  end
end

input = ARGF.read.chomp.split(",")
part_1 = input.sum { |step| hash(step) }
puts "Part 1: #{part_1}"

boxes = Hash.new { |h, k| h[k] = [] }
input.each do |step|
  label, operation, focal_length = step.scan(/\A(\w+)([-=])(\d*)\z/).first
  box_number = hash(label)

  if operation == "-"
    boxes[box_number].delete_if { _1[0] == label }
  else
    if (slot = boxes[box_number].index { _1[0] == label })
      boxes[box_number][slot][1] = focal_length.to_i
    else
      boxes[box_number] << [label, focal_length.to_i]
    end
  end

  puts "After \"#{step}\":"
  boxes.each do |box_number, contents|
    contents_string = contents.map { |(label, focal_length)| "#{label} #{focal_length}" }.join("] [")
    puts "Box #{box_number}: [#{contents_string}]"
  end
  puts
end

part_2 = boxes.flat_map do |box_number, contents|
  contents.map.with_index(1) do |(label, focal_length), slot|
    (box_number + 1) * slot * focal_length
  end
end

puts "Part 2: #{part_2.sum}"
