# frozen_string_literal: true

def calculate_ways_to_win(duration, distance_record)
  duration.times.count do |hold_time|
    remaining_time = duration - hold_time
    distance = remaining_time * hold_time
    distance > distance_record
  end
end

times_string, distances_string = ARGF.readlines(chomp: true)

_, *times = times_string.split.map(&:to_i)
_, *distances = distances_string.split.map(&:to_i)

races = times.zip(distances)

ways_to_win = races.map do |duration, distance_record|
  calculate_ways_to_win(duration, distance_record)
end

part_1 = ways_to_win.inject(:*)
puts "Part 1: #{part_1}"

part_2 = calculate_ways_to_win(times.join.to_i, distances.join.to_i)
puts "Part 2: #{part_2}"
