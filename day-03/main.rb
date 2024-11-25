# frozen_string_literal: true

DELTAS = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]].freeze

engine_schematic = ARGF.readlines(chomp: true)

max_y = engine_schematic.length - 1
max_x = engine_schematic.first.length - 1

part_numbers = []
gears = Hash.new { |h, k| h[k] = [] }

engine_schematic.each_with_index do |line, y_index|
  part_matches = line.to_enum(:scan, /(\d+)/).map { Regexp.last_match }
  part_matches.each do |match_data|
    start_x, end_x = match_data.offset(0)

    neighbours = (start_x...end_x).flat_map do |x_index|
      DELTAS.map { |yd, xd| [y_index + yd, x_index + xd] }
    end
    neighbours.uniq!
    neighbours.reject! { |y, x| y < 0 || x < 0 || y > max_y || x > max_x }

    if neighbours.any? { |y, x| engine_schematic[y][x].match?(/[^\d.]/) }
      part_number = match_data.captures.first.to_i
      part_numbers << part_number

      adjacent_gears = neighbours.select { |y, x| engine_schematic[y][x].match?(/\*/) }
      adjacent_gears.each do |coords|
        gears[coords] << part_number
      end
    end
  end
end

part_1 = part_numbers.sum
puts "Part 1: #{part_1}"

part_2 = gears.values.select { _1.size == 2 }.sum { _1 * _2 }
puts "Part 2: #{part_2}"
