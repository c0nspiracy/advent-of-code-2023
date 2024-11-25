# frozen_string_literal: true
#
EXPANSION_FACTOR = ENV.fetch("EXPANSION_FACTOR", 1_000_000).to_i

image = ARGF.readlines(chomp: true).map(&:chars)

row_indices_to_expand = image.each_index.select { |n| image[n].uniq == ["."] }
image = image.transpose
column_indices_to_expand = image.each_index.select { |n| image[n].uniq == ["."] }
image = image.transpose

galaxies = []
image.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    galaxies << [y, x] if cell == "#"
  end
end

part_2 = galaxies.combination(2).sum do |(y1, x1), (y2, x2)|
  y_expansion = EXPANSION_FACTOR * row_indices_to_expand.count { |i| i.between?(y1, y2) }
  x_expansion = EXPANSION_FACTOR * column_indices_to_expand.count { |i| i.between?(x1, x2) }
  y_expansion + x_expansion + (y2 - y1).abs + (x2 - x1).abs
end

puts "Part 2: #{part_2}"
