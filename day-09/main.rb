# frozen_string_literal: true

input = ARGF.readlines(chomp: true)

histories = input.map do |line|
  line.split.map(&:to_i)
end

extrapolated_values = histories.map do |history|
  stack = [history]

  loop do
    current_sequence = stack.last
    break if current_sequence.all?(&:zero?)

    new_sequence = current_sequence.each_cons(2).map { _2 - _1 }
    stack.push new_sequence
  end

  backwards_value = 0
  forwards_value = 0

  until stack.empty?
    current_sequence = stack.pop
    backwards_value = current_sequence.first - backwards_value
    forwards_value = current_sequence.last + forwards_value
  end

  [forwards_value, backwards_value]
end

part_1, part_2 = extrapolated_values.transpose.map(&:sum)
puts "Part 1: #{part_1}"
puts "Part 2: #{part_2}"
