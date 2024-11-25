# # frozen_string_literal: true

input = ARGF.readlines(chomp: true).map { _1.chars.map(&:to_i) }
binding.irb
