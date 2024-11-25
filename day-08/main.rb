# # frozen_string_literal: true

input = ARGF.readlines(chomp: true)

instruction_string, _, *node_strings = input
instructions = instruction_string.chars.cycle

start_nodes = []
turns = {}

node_strings.map do |node_string|
  node_string.scan(/\A(\w+) = \((\w+), (\w+)\)\z/) do |name, left, right|
    start_nodes << name if name.end_with?("A")
    turns[name] = {"L" => left, "R" => right}
  end
end

current_nodes = start_nodes.map.with_index.to_h { [_2, _1] }
steps = Hash.new(0)

loop do
  break if current_nodes.empty?

  instruction = instructions.next

  current_nodes.each_key do |key|
    current_node = current_nodes[key]
    start_node = start_nodes[key]

    steps[start_node] += 1
    current_node = turns[current_node][instruction]

    current_nodes[key] = current_node.end_with?("Z") ? nil : current_node
  end

  current_nodes.compact!
end

part_1 = steps["AAA"]
part_2 = steps.values.inject(:lcm)
puts "Part 1: #{part_1}"
puts "Part 2: #{part_2}"
