# frozen_string_literal: true

DIGITS = ("1".."9").map { [_1, _1] }.to_h.freeze
DIGIT_WORDS = {
  "one" => "1",
  "two" => "2",
  "three" => "3",
  "four" => "4",
  "five" => "5",
  "six" => "6",
  "seven" => "7",
  "eight" => "8",
  "nine" => "9"
}.freeze
DIGIT_WORDS_REVERSE = DIGIT_WORDS.transform_keys(&:reverse)

SUB_FWD = DIGITS.merge(DIGIT_WORDS)
SUB_REV = DIGITS.merge(DIGIT_WORDS_REVERSE)

input = ARGF.readlines(chomp: true)
part_1 = input.sum do |line|
  line.scan(/\d/).values_at(0, -1).join.to_i
end

part_2 = input.sum do |line|
  line.sub!(Regexp.union(SUB_FWD.keys), SUB_FWD)
  line = line.reverse.sub(Regexp.union(SUB_REV.keys), SUB_REV).reverse
  line.scan(/\d/).values_at(0, -1).join.to_i
end

puts "Part 1: #{part_1}"
puts "Part 2: #{part_2}"
