# frozen_string_literal: true

image = ARGF.readlines(chomp: true).map(&:chars)

indices_to_expand = image.each_index.select { |n| image[n].uniq == ["."] }

puts image.length
indices_to_expand.each_with_index do |index, offset|
  image.insert(index + offset, image[index + offset])
end

image = image.transpose

indices_to_expand = image.each_index.select { |n| image[n].uniq == ["."] }

puts image.length
indices_to_expand.each_with_index do |index, offset|
  image.insert(index + offset, image[index + offset])
end
image = image.transpose

galaxies = []
image.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    galaxies << [y, x] if cell == "#"
  end
end

part_1 = galaxies.combination(2).sum do |galaxy_1, galaxy_2|
  (galaxy_1[0] - galaxy_2[0]).abs + (galaxy_1[1] - galaxy_2[1]).abs
end
puts "Part 1: #{part_1}"
