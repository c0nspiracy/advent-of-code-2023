# frozen_string_literal: true

almanac = ARGF.readlines(chomp: true)

seed_listing, *map_listings = almanac.chunk { _1.empty? ? :_separator : true }.map(&:last)

seeds = seed_listing.last.split(": ").last.split.map(&:to_i)

mappings = Hash.new { |h, k| h[k] = {} }
mapping_to = {}

map_listings.each do |name_part, *number_parts|
  source_name, destination_name = name_part.scan(/(\w+)-to-(\w+) map:/).first
  mapping_to[source_name] = destination_name

  number_parts.each do |number_part|
    destination_range_start, source_range_start, range_length = number_part.split.map(&:to_i)
    source_range = source_range_start...(source_range_start + range_length)

    mappings[source_name][source_range] = destination_range_start
  end
end

def find_mapping(mappings, mapping_to, source:, number:)
  mapping = mappings[source]
  result = mapping.detect { |range, _| range.cover?(number) }
  to = mapping_to[source]
  return [to, number] if result.nil?

  range, destination_range_start = result
  [to, destination_range_start + (number - range.begin)]
end

location_numbers = seeds.map do |number|
  type = "seed"
  loop do
    break if type == "location"

    type, number = find_mapping(mappings, mapping_to, source: type, number: number)
  end
  number
end

part_1 = location_numbers.min
puts "Part 1: #{part_1}"

part_2_seeds = seeds.each_slice(2).flat_map { (_1...(_1+_2)).to_a }
location_numbers = part_2_seeds.map do |number|
  type = "seed"
  loop do
    break if type == "location"

    type, number = find_mapping(mappings, mapping_to, source: type, number: number)
  end
  number
end

part_2 = location_numbers.min
puts "Part 2: #{part_2}"
