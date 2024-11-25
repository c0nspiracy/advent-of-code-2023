# frozen_string_literal: true

PART_2_CYCLES = 1_000_000_000

class Platform
  ROUNDED_ROCK = "O"
  CUBE_ROCK = "#"

  def initialize(grid)
    @grid = grid
  end

  def spin_cycle
    tilt_north
    tilt_west
    tilt_south
    tilt_east
  end

  def id
    pos = []
    @grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        pos << [y, x] if cell == ROUNDED_ROCK
      end
    end
    pos.hash
  end

  def display
    @grid.each do |row|
      puts row.join
    end
    puts
    nil
  end

  def tilt_north
    transform_transposed do |grid|
      grid.map { |row| tilt_row(row, reverse: true) }
    end
    nil
  end

  def tilt_south
    transform_transposed do |grid|
      grid.map { |row| tilt_row(row, reverse: false) }
    end
    nil
  end

  def tilt_east
    @grid.map! { |row| tilt_row(row, reverse: false) }
    nil
  end

  def tilt_west
    @grid.map! { |row| tilt_row(row, reverse: true) }
    nil
  end

  def north_beam_load
    @grid.reverse_each.with_index(1).sum do |row, load|
      load * row.count(ROUNDED_ROCK)
    end
  end

  private

  def transform_transposed
    @grid = yield(@grid.transpose).transpose
  end

  def tilt_row(row, reverse: true)
    chunks = row.chunk { |cell| cell == CUBE_ROCK }
    chunks.flat_map do |barrier, cells|
      next cells if barrier

      reverse ? cells.sort.reverse : cells.sort
    end
  end
end

input = ARGF.readlines(chomp: true).map(&:chars)

platform = Platform.new(input)
platform.tilt_north
part_1 = platform.north_beam_load
puts "Part 1: #{part_1}"

platform = Platform.new(input)
cycles = 0
loops = Hash.new { |h, k| h[k] = [] }
loops[platform.id] = [0]

loop do
  platform.spin_cycle
  cycles += 1
  id = platform.id
  loops[id] << cycles
  if loops[id].size > 1
    loop_size = loops[id][1] - loops[id][0]
    target = (PART_2_CYCLES - cycles) % loop_size
    target.times { platform.spin_cycle }
    break
  end
end

part_2 = platform.north_beam_load
puts "Part 2: #{part_2}"
