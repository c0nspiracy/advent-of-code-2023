# frozen_string_literal: true

require "matrix"

DIRECTIONS = {
  "R" => Vector[0, 1],
  "L" => Vector[0, -1],
  "U" => Vector[-1, 0],
  "D" => Vector[1, 0]
}.freeze

DELTAS = DIRECTIONS.values
DIAG = [
 Vector[-1, -1],
 Vector[-1, 1],
 Vector[1, -1],
 Vector[1, 1]
]
EIGHT_DELTAS = DELTAS + DIAG

def calculate_grid_squares_count(polygon_vertices)
  # Ensure that the array has at least three vertices
  return 0 if polygon_vertices.length < 3

  # Extract the x and y coordinates separately
  x_coordinates, y_coordinates = polygon_vertices.transpose

  # Find the bounding box of the polygon
  min_x, max_x = x_coordinates.min, x_coordinates.max
  min_y, max_y = y_coordinates.min, y_coordinates.max

  # Initialize the count of grid squares
  grid_squares_count = 0

  # Iterate through each grid square in the bounding box
  (min_x..max_x).each do |x|
    (min_y..max_y).each do |y|
      # Check if the grid square is inside the polygon
      if point_inside_polygon?(x, y, polygon_vertices)
        grid_squares_count += 1
      end
    end
  end

  grid_squares_count
end

def point_inside_polygon?(x, y, polygon_vertices)
  # Ray casting algorithm to determine if a point is inside the polygon

  inside = false
  n = polygon_vertices.length

  (0...n).each do |i|
    x1, y1 = polygon_vertices[i]
    x2, y2 = polygon_vertices[(i + 1) % n]

    # Check if the point is on the polygon edge
    if (y1 == y && y2 == y) && (x.between?(x1, x2) || x.between?(x2, x1))
      return true
    end

    # Check if the ray crosses the polygon edge
    if (y1 > y) != (y2 > y) && x < ((x2 - x1) * (y - y1) / (y2 - y1).to_f + x1)
      inside = !inside
    end
  end

  inside
end

def display(positions, hl = {})
  (min_y, max_y), (min_x, max_x) = minmax_positions(positions)
  (min_y..max_y).each do |y|
    line = (min_x..max_x).map do |x|
      pos = Vector[y, x]
      cell = positions.include?(pos) ? "#" : "."
      if hl.key?(pos)
        "\033[32mX\033[0m"
      else
        cell
      end
    end
    puts line.join
  end
  puts
end

def minmax_positions(positions)
  positions.map(&:to_a).transpose.map { _1.uniq.minmax }
end

def minmax_row(positions)
  positions.map { _1[1] }.minmax
end

dig_plan = ARGF.readlines(chomp: true).map do |line|
  direction, meters, color = line.scan(/\A([UDLR]) (\d+) \(#(\h{6})\)\z/).first
  [direction, meters.to_i, color]
end

pos = Vector[0, 0]
trench = { pos => true }

shoelace = [[0,0]]
boundary_length = 0
dig_plan.each do |direction, meters, _color|
  boundary_length += meters
  meters.times do |n|
    pos += DIRECTIONS[direction]
    trench[pos] = true
  end
  shoelace << [pos[1], pos[0]]
end
#shoelace.pop

def calculate_pick_algorithm(polygon_vertices)
  # Ensure that the array has at least three vertices
  return 0 if polygon_vertices.length < 3

  # Calculate the area using the Shoelace Algorithm
  area = calculate_manhattan_polygon_area(polygon_vertices)

  # Calculate the number of boundary points
  boundary_points = calculate_boundary_points(polygon_vertices)

binding.irb
  # Apply Pick's Algorithm
  inside_points = area - boundary_points / 2 + 1
  inside_points.to_i
end

def calculate_manhattan_polygon_area(vertices)
  # Shoelace Algorithm to calculate the area
  area = 0
  n = vertices.length

  (0...n).each do |i|
    j = (i + 1) % n
    area += vertices[i][0] * vertices[j][1] - vertices[j][0] * vertices[i][1]
  end

  area = area.abs / 2.0
  area
end

def calculate_boundary_points(vertices)
  # Count the number of grid points on the boundary using the Bresenham's Line Algorithm
  boundary_points = 0
  n = vertices.length

  (0...n).each do |i|
    x1, y1 = vertices[i]
    x2, y2 = vertices[(i + 1) % n]

    # Apply Bresenham's Line Algorithm
    dx = (x2 - x1).abs
    dy = (y2 - y1).abs
    sx = x1 < x2 ? 1 : -1
    sy = y1 < y2 ? 1 : -1
    err = dx - dy

    while true
      # Count the boundary point
      boundary_points += 1

      if x1 == x2 && y1 == y2
        break
      end

      e2 = 2 * err

      if e2 > -dy
        err -= dy
        x1 += sx
      end

      if e2 < dx
        err += dx
        y1 += sy
      end
    end
  end

  boundary_points
end

# Example usage:
shoelace.pop
polygon_vertices = shoelace.map(&:to_a)
grid_squares_count = calculate_pick_algorithm(polygon_vertices)
puts "Number of grid squares inside and on the edge of the polygon: #{grid_squares_count}"

binding.irb

(min_y, max_y), (min_x, max_x) = minmax_positions(trench.keys)

start_poss = EIGHT_DELTAS.map { |d| pos + d }.reject { |p| trench.key?(p) }

def bfs(start_pos, seen, y_bounds, x_bounds)
  q = [start_pos]

  loop do
    break if q.empty?

    pos = q.pop
    return :out_of_bounds unless y_bounds.cover?(pos[0]) && x_bounds.cover?(pos[1])

    next if seen.key?(pos)

    new_pos = DELTAS.map { |d| pos + d }.reject { |p| seen.key?(p) || q.include?(p) }
    q.push(*new_pos)

    seen[pos] = true
    puts "Queue size: #{q.size}"
  end

  seen
end

x_bounds = (min_x..max_x)
y_bounds = (min_y..max_y)
seen = nil
loop do
  break if start_poss.empty?

  start_pos = start_poss.shift
  puts "Trying from #{start_pos}"
  seen = bfs(start_pos, trench.dup, y_bounds, x_bounds)

  break unless seen == :out_of_bounds
end

raise "FATAL ERROR!" if seen == :out_of_bounds

part_1 = seen.size
puts "Part 1: #{part_1}"

