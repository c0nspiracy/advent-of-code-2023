# frozen_string_literal: true

input = ARGF.readlines(chomp: true)
cards = {}
input.each do |line|
  card_string, numbers_string = line.split(": ")
  card_id = card_string.scan(/\d+/).first.to_i
  winning_number_string, elf_number_string = numbers_string.split(" | ")
  winning_numbers = winning_number_string.split.map(&:to_i)
  elf_numbers = elf_number_string.split.map(&:to_i)
  matches = winning_numbers & elf_numbers
  cards[card_id] = matches.size 
end

part_1 = cards.values.sum do |matches|
  matches.zero? ? 0 : 2 ** (matches - 1)
end
puts "Part 1: #{part_1}"

instances = cards.keys.product([1]).to_h
cards.each do |card_id, matches|
  matches.times do |n|
    instances[card_id + n + 1] += instances[card_id]
  end
end

puts "Part 2: #{instances.values.sum}"
