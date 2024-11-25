# frozen_string_literal: true

PART_1_LIMITS = {
  "red" => 12,
  "green" => 13,
  "blue" => 14
}.freeze

input = ARGF.readlines(chomp: true)

games = Hash.new { |h, k| h[k] = [] }

input.each do |line|
  meta, line = line.split(": ")
  game_id = meta.scan(/\d+/).first.to_i
  draws = line.split("; ")
  draws.each do |draw|
    cubes = draw.split(", ")
    games[game_id] << cubes.each_with_object({}) do |cube, memo|
      amount, colour = cube.split(" ")
      memo[colour] = amount.to_i
    end.to_h
  end
end

possible_games = games.select do |_game_id, draws|
  draws.all? do |draw|
    draw.all? do |colour, amount|
      amount <= PART_1_LIMITS[colour]
    end
  end
end

part_1 = possible_games.keys.sum
puts "Part 1: #{part_1}"

fewest_cubes = games.map do |_game_id, draws|
  draws.reduce do |draw, other|
    draw.merge(other) do |_key, amount, other_amount|
      [amount, other_amount].max
    end
  end
end

part_2 = fewest_cubes.sum { |draws| draws.values.inject(:*) }
puts "Part 2: #{part_2}"
