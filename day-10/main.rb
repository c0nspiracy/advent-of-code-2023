# frozen_string_literal: true

require "matrix"

TILES = [
  GROUND = ".",
  START = "S",
  H_PIPE = "-",
  V_PIPE = "|",
  NE_BEND = "L",
  NW_BEND = "J",
  SW_BEND = "7",
  SE_BEND = "F"
]

NORTH = [-1, 0]
SOUTH = [1, 0]
EAST = [0, 1]
WEST = [0, -1]

DIRECTION_ARROWS = {
  Set[NORTH, WEST] => "↖",
  Set[NORTH, EAST] => "↗",
  Set[SOUTH, EAST] => "↘",
  Set[SOUTH, WEST] => "↙"
}

TILE_NEIGHBOURS = {
  H_PIPE => [EAST, WEST],
  V_PIPE => [NORTH, SOUTH],
  NE_BEND => [NORTH, EAST],
  NW_BEND => [NORTH, WEST],
  SW_BEND => [SOUTH, WEST],
  SE_BEND => [SOUTH, EAST]
}

IDENTITY_MAPPING = TILES.map { [_1, _1] }.to_h
PRETTY_MAPPING = {
  GROUND => GROUND,
  START => START,
  H_PIPE => "\u2500",
  V_PIPE => "\u2502",
  NE_BEND => "\u2514",
  NW_BEND => "\u2518",
  SW_BEND => "\u2510",
  SE_BEND => "\u250C"
}

def display(grid, character_set)
  grid.each do |row|
    line = row.map do |tile|
      character_set[tile]
    end
    puts line.join
  end
  puts
  nil
end

def display_interior(grid, interior, distances, current_position)
  grid.each_with_index do |row, y|
    line = row.map.with_index do |tile, x|
      if current_position == [y, x]
        "\033[35m#{PRETTY_MAPPING[tile]}\033[0m"
      elsif interior.key?([y, x])
        "\033[44m#{PRETTY_MAPPING[tile]}\033[0m"
      elsif distances.key?([y, x])
        "\033[32m#{PRETTY_MAPPING[tile]}\033[0m"
      else
        PRETTY_MAPPING[tile]
      end
    end
    puts line.join
  end
  puts
  nil
end

def display_distances(grid, distances, hl = false)
  grid.each_with_index do |row, y|
    line = row.map.with_index do |tile, x|
      if distances.key?([y, x])
        if hl
          "\033[32m#{PRETTY_MAPPING[tile]}\033[0m"
        else
          distances[[y, x]]
        end
      else
        PRETTY_MAPPING[tile]
      end
    end
    puts line.join
  end
  puts
  nil
end

class Grid
  DELTAS = [[-1, 0], [0, -1], [0, 1], [1, 0]].freeze

  def initialize(grid)
    @grid = grid
  end

  def neighbours_of(y, x)
    DELTAS.map { |dy, dx| [dy + y, dx + x] }.reject { |ny, nx| out_of_bounds?(ny, nx) }
  end

  def out_of_bounds?(y, x)
    y < 0 || x < 0 || y > max_y || x > max_x
  end

  private

  def max_y
    @max_y ||= @grid.size - 1
  end

  def max_x
    @max_x ||= @grid.first.size - 1
  end
end

class Node
  attr_reader :tile, :y, :x
  attr_accessor :next, :prev

  def initialize(tile, y, x)
    @tile = tile
    @y = y
    @x = x
    @next = nil
    @prev = nil
  end

  def to_s
    "#<Node [#{tile}] y: #{y}, x: #{x}>"
  end
  alias_method :inspect, :to_s

  def coords
    [y, x]
  end

  def canonical_type
    @canonical_type ||= if tile == START
      start_neighbour_relative_positions = [
        (Vector[*self.next.coords] - Vector[*coords]).to_a,
        (Vector[*self.prev.coords] - Vector[*coords]).to_a
      ].sort
      TILE_NEIGHBOURS.detect do |_, neighbours|
        neighbours.sort == start_neighbour_relative_positions
      end.first
    else
      tile
    end
  end
end

def display_raw(grid) = display(grid, IDENTITY_MAPPING)

def display_pretty(grid) = display(grid, PRETTY_MAPPING)

tiles = ARGF.readlines(chomp: true).map(&:chars)
display_raw(tiles)
display_pretty(tiles)

start_y = tiles.index { _1.include?(START) }
start_x = tiles[start_y].index(START)
start_node = Node.new(START, start_y, start_x)

grid = Grid.new(tiles)
grid.neighbours_of(start_y, start_x).each do |ny, nx|
  tile = tiles[ny][nx]
  delta = [start_y - ny, start_x - nx]

  if (valid_neighbour_deltas = TILE_NEIGHBOURS[tile])
    if valid_neighbour_deltas.include?(delta)
      next_node = Node.new(tile, ny, nx)
      if start_node.next.nil?
        next_node.prev = start_node
        start_node.next = next_node
      elsif start_node.prev.nil?
        next_node.next = start_node
        start_node.prev = next_node
      else
        raise "Impossible"
      end
    end
  end
end

current_node = start_node.next
found_it = true

loop do
  binding.irb unless found_it

  found_it = false
  break if current_node == start_node

  grid.neighbours_of(current_node.y, current_node.x).each do |ny, nx|
    next if current_node.prev.y == ny && current_node.prev.x == nx
    tile = tiles[ny][nx]
    delta = [-(current_node.y - ny), -(current_node.x - nx)]

    if (valid_neighbour_deltas = TILE_NEIGHBOURS[current_node.tile])
      if valid_neighbour_deltas.include?(delta)
        if tile == START
          current_node.next = start_node
          start_node.prev = current_node
          current_node = start_node
        else
          next_node = Node.new(tile, ny, nx)
          next_node.prev = current_node
          current_node.next = next_node
          current_node = next_node
        end
        found_it = true
        break
      end
    end
  end
end

current_node = start_node
distances = Hash.new(Float::INFINITY)
distance = 0
loop do
  distances[current_node.coords] = [distance, distances[current_node.coords]].min

  distance += 1
  current_node = current_node.next

  break if current_node == start_node
end

current_node = start_node
distance = 0

loop do
  distances[current_node.coords] = [distance, distances[current_node.coords]].min

  distance += 1
  current_node = current_node.prev

  break if current_node == start_node
end

display_distances(tiles, distances, true)
part_1 = distances.values.max
puts "Part 1: #{part_1}"

current_node = start_node
inner_lining = {}
allowed_directions = []

loop do
  if [H_PIPE, V_PIPE].include?(current_node.canonical_type)
    next_node = current_node.next
    #delta = (Vector[*next_node.coords] - Vector[*current_node.coords]).to_a
    delta = nil
    (allowed_directions - [delta]).each do |dy, dx|
      pos = (Vector[*current_node.coords] + Vector[dy, dx]).to_a
      puts "Checking #{pos.join(", ")}"
      inner_lining[pos] = true unless distances.key?(pos)
    end
  else
    allowed_directions_was = allowed_directions
    allowed_directions = TILE_NEIGHBOURS[current_node.canonical_type]
    unless allowed_directions_was.empty?
      if (allowed_directions_was & allowed_directions).empty?
        adws = allowed_directions_was.to_set
        if adws == Set[SOUTH, EAST]
          if current_node.canonical_type == NW_BEND
            allowed_directions = [NORTH, EAST]
          else
            binding.irb
          end
        elsif adws == Set[NORTH, EAST]
          if current_node.canonical_type == SW_BEND
            allowed_directions = [NORTH, WEST]
          else
            binding.irb
          end
        elsif adws == Set[NORTH, WEST]
          if current_node.canonical_type == SE_BEND
            allowed_directions = [SOUTH, WEST]
          else
            binding.irb
          end
        elsif adws == Set[SOUTH, WEST]
          if current_node.canonical_type == NE_BEND
            allowed_directions = [SOUTH, EAST]
          else
            binding.irb
          end
        else
          binding.irb
        end
      end
      puts "Search direction changed from #{DIRECTION_ARROWS[allowed_directions_was.to_set]} to #{DIRECTION_ARROWS[allowed_directions.to_set]}"
    end
  end

  display_interior(tiles, inner_lining, distances, current_node.coords)
  puts "Search direction: #{DIRECTION_ARROWS[allowed_directions.to_set]}"
  gets
  current_node = current_node.next
  break if current_node == start_node
end

display_interior(tiles, inner_lining, distances, current_node.coords)

binding.irb
__END__
####
# BFS

seen = {}
queue = []

deltas_from_start_node = []
sncy, sncx = start_node.coords
snncy, snncx = start_node.next.coords
snpcy, snpcx = start_node.prev.coords
deltas_from_start_node << [snncy - sncy, snncx - sncx]
deltas_from_start_node << [snpcy - sncy, snpcx - sncx]

seen[start_node.coords] = true
queue = [
  [start_node.next.coords, deltas_from_start_node],
  # [[sncy + deltas_from_start_node[0][0] + deltas_from_start_node[1][0], sncx + deltas_from_start_node[0][1] + deltas_from_start_node[1][1]], deltas_from_start_node],
  [start_node.prev.coords, deltas_from_start_node]
]

loop do
  break if queue.empty?

  current_position, search_directions = queue.shift
  seen[current_position] = true

  if distances.key?(current_position)
    # On the loop
    search_directions.each do |sd|
      queue << [[current_position[0] + sd[0], current_position[1] + sd[1]], search_directions]
    end

  end

  binding.irb
end
binding.irb
