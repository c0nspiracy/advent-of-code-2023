# frozen_string_literal: true

require_relative "./beam"
require_relative "./mutating_beam"
require "matrix"

def display(grid, energised)
  grid.each_with_index do |row, y|
    line = row.map.with_index do |cell, x|
      pos = Vector[y, x]
      if cell == "."
        if energised.key?(pos)
          if energised[pos].size > 1
            energised[pos].size.to_s
          else
            energised[pos].first
          end
        else
          "."
        end
      else
        cell
      end
    end
    puts line.join
  end
  puts
end

def display_beam(grid, beam)
  grid.each_with_index do |row, y|
    line = row.join
    line2 = row.map.with_index do |cell, x|
      pos = Vector[y, x]
      if (char = beam.debug_position(pos))
        char
      else
        cell
      end
    end
    puts "#{line} #{line2.join}"
  end
  puts
end

def display_energised(grid, energised)
  grid.each_with_index do |row, y|
    line = row.map.with_index do |cell, x|
      pos = Vector[y, x]
      energised.key?(pos) ? "#" : "."
    end
    puts line.join
  end
  puts
end

beams = [MutatingBeam.new]
energised = Hash.new { |h, k| h[k] = Set.new }
beams.each { |beam| energised[beam.position] << beam.d }

grid = ARGF.readlines(chomp: true).map(&:chars)
max_y = grid.size - 1
max_x = grid.first.size - 1

loops = 0
break_after_loop = -1
last_energised_tile_count = energised.size

beam_spawn_locations = Set.new
#beams.each { |beam| beam_spawn_locations << beam.position }

loop do
  puts "Loop ##{loops}, #{beams.size} active beams"
  break if beams.empty?

  pre_size = beams.size
  stats = Hash.new(0)
  beams = beams.flat_map do |beam|
    beam_y, beam_x = beam.position.to_a
    cell = grid[beam_y][beam_x]
    case cell
    when "."
      stats[:empty] += 1
      beam
    when "/", "\\"
      stats[:reflect] += 1
      beam.reflect(cell)
    when "-", "|"
      stats[:split] += 1
      beam.split(cell)
    else
      raise "Unknown cell: #{cell}"
    end
  end
  stat_message = stats.map { |k,v| "#{v} #{k}" }.join(", ")
  puts "After processing #{stat_message}: #{pre_size} --> #{beams.size}"

  pre_cull = beams.size
  beams.reject! do |beam|
    beam.new_beam? && beam_spawn_locations.include?([beam.position, beam.direction])
  end
  post_cull = beams.size
  cull_diff = pre_cull - post_cull
  #binding.irb if cull_diff > 0
  puts "Culled #{cull_diff} newly formed beams that had already been spawned from that location in that direction" if cull_diff > 0

  beams.select(&:new_beam?).each { |beam| beam_spawn_locations << [beam.position, beam.direction] }

  #beams.map!(&:advance)
  beams.each(&:advance)

  pre_oob = beams.size
  beams.reject! do |beam|
    y, x = beam.position.to_a
    x < 0 || x > max_x || y < 0 || y > max_y
  end
  post_oob = beams.size
  diff_oob = pre_oob - post_oob
  puts "Removed #{diff_oob} out-of-bounds beams" if diff_oob > 0

  #new_cells_energised = false
  beams.each do |beam|
    #new_cells_energised = true unless energised.key?(beam.position)
    energised[beam.position] << beam.d
  end

  # pre_looped = beams.size
  # beams.reject!(&:looped?)
  # post_looped = beams.size
  # diff_looped = pre_looped - post_looped
  # puts "Removed #{diff_looped} looped beams" if diff_looped > 0
  #puts "Removed #{deleted.size} looped beams" unless deleted.empty?

  puts "Ending loop with #{beams.size} beams"

  # break if break_after_loop == loops
  # if break_after_loop == -1
  #   new_cells_energised = energised.size > last_energised_tile_count
  #   unless new_cells_energised
  #     break_after_loop = loops + 100
  #     puts "Breaking after #{break_after_loop} loops"
  #   end
  # end
  loops += 1
  #puts "Loop #{loops}, #{beams.size} beams, #{energised.size} energised tiles" if break_after_loop > 0 || loops % 10 == 0

  #break if loops > 30
  #display(grid, energised)
  #last_energised_tile_count = energised.size
  #binding.irb
  puts "-"*80
end
puts loops

display(grid, energised)
display_energised(grid, energised)

puts "Part 1: #{energised.size}"
