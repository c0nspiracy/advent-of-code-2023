# frozen_string_literal: true

require_relative "./beam"
require_relative "./mutating_beam"
require_relative "./grid_display"
require "matrix"

class Grid
  include GridDisplay

  def initialize(grid, initial_position: Vector[0, 0], initial_direction: Vector[0, 1], debug: false)
    @grid = grid
    @debug = debug
    @beams = [MutatingBeam.new(position: initial_position, direction: initial_direction)]
    @energised = Hash.new { |h, k| h[k] = Set.new }
    @energised[initial_position] << initial_direction
  end

  def energised_cells
    @energised.size
  end

  def simulate
    loops = 0
    beam_spawn_locations = Set.new

    loop do
      puts "Loop ##{loops}, #{beams.size} active beams" if @debug
      break if @beams.empty?

      pre_size = @beams.size
      stats = Hash.new(0)
      @beams = @beams.flat_map do |beam|
        beam_y, beam_x = beam.position.to_a
        cell = @grid[beam_y][beam_x]
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
      puts "After processing #{stat_message}: #{pre_size} --> #{@beams.size}" if @debug

      pre_cull = @beams.size
      @beams.reject! do |beam|
        beam.new_beam? && beam_spawn_locations.include?([beam.position, beam.direction])
      end
      post_cull = @beams.size
      cull_diff = pre_cull - post_cull
      puts "Culled #{cull_diff} newly formed beams that had already been spawned from that location in that direction" if @debug && cull_diff > 0

      @beams.select(&:new_beam?).each { |beam| beam_spawn_locations << [beam.position, beam.direction] }

      @beams.each(&:advance)

      pre_oob = @beams.size
      @beams.reject! do |beam|
        y, x = beam.position.to_a
        x < 0 || x > max_x || y < 0 || y > max_y
      end
      post_oob = @beams.size
      diff_oob = pre_oob - post_oob
      puts "Removed #{diff_oob} out-of-bounds beams" if @debug && diff_oob > 0

      @beams.each do |beam|
        @energised[beam.position] << beam.d
      end

      puts "Ending loop with #{@beams.size} beams" if @debug

      loops += 1
    end
  end

  private

  def max_y
    @max_y ||= @grid.size - 1
  end

  def max_x
    @max_x ||= @grid.first.size - 1
  end
end

debug = ENV.fetch("DEBUG", "false") == "true"
grid_array = ARGF.readlines(chomp: true).map(&:chars)

grid = Grid.new(grid_array, debug: debug)
grid.simulate
puts "Part 1: #{grid.energised_cells}"

height = grid_array.size - 1
width = grid_array.first.size - 1
configurations = []

(0..height).each do |y|
  configurations << [Vector[y, 0], Vector[0, 1]]
  configurations << [Vector[y, width], Vector[0, -1]]
end

(0..width).each do |x|
  configurations << [Vector[0, x], Vector[1, 0]]
  configurations << [Vector[height, x], Vector[-1, 0]]
end

results = configurations.map do |position, direction|
  grid = Grid.new(grid_array, initial_position: position, initial_direction: direction, debug: debug)
  grid.simulate
  result = grid.energised_cells

  puts "Simulating position #{position}, direction #{direction} --> #{result}"
  result
end

puts "Part 2: #{results.max}"
