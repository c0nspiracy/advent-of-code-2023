# frozen_string_literal: true

require_relative "./hand"
require_relative "./hand_with_jokers"

input = ARGF.readlines(chomp: true)

hands = []
hands_with_jokers = []

input.each do |line|
  cards, bid = line.split
  hands << Hand.new(cards.chars, bid.to_i)
  hands_with_jokers << HandWithJokers.new(cards.chars, bid.to_i)
end

part_1 = hands.sort.reverse.each.with_index(1).sum do |hand, rank|
  hand.bid * rank
end

part_2 = hands_with_jokers.sort.reverse.each.with_index(1).sum do |hand, rank|
  hand.bid * rank
end

puts "Part 1: #{part_1}"
puts "Part 2: #{part_2}"
