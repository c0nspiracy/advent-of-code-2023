# frozen_string_literal: true

class Graph
  def initialize(adj_list)
    @adj_list = adj_list # Hash.new { |hash, key| hash[key] = [] }
  end

  def add_edge(node1, node2)
    @adj_list[node1] << node2
    @adj_list[node2] << node1 # Assuming an undirected graph
  end

  def longest_path_steps(start, finish)
    visited = Set.new
    @max_path_length = 0
    @max_path = []

    dfs(start, finish, [], visited)

    @max_path.length - 1
  end

  def longest_path_steps_stack_broken(start, finish)
    visited = Set.new
    max_path_length = 0
    max_path = []
    stack = []

    stack.push([start, [start]])

    until stack.empty?
      current, path = stack.pop
      visited.add(current)

      if current == finish && path.length > max_path_length
        max_path = path.dup
        max_path_length = path.length
      end

      @adj_list[current].each do |neighbor|
        next if visited.include?(neighbor)

        new_path = path.map(&:dup)
        new_path.push(neighbor)
        stack.push([neighbor, new_path])
      end
    end

    max_path_length - 1
  end

  def longest_path_steps_stack(start, finish)
    visited = Set.new
    max_path_length = 0
    max_path = []
    stack = [[start, [start]]]

    until stack.empty?
      current, path = stack.pop

      unless visited.include?(current)
        visited.add(current)

        if current == finish && path.length > max_path_length
          max_path = path.dup
          max_path_length = path.length
        end

        @adj_list[current].each do |neighbor|
          unless visited.include?(neighbor)
            new_path = path.map(&:dup)
            new_path.push(neighbor)
            stack.push([neighbor, new_path]) #unless visited.include?(neighbor)
          end
        end
      end
    end

    max_path_length - 1
  end

  private

  def dfs(current, finish, path, visited)
    visited.add(current)
    path.push(current)

    if current == finish && path.length > @max_path_length
      @max_path = path.dup
      @max_path_length = path.length
    end

    binding.irb if @adj_list[current].nil?
    @adj_list[current].each do |neighbor|
      dfs(neighbor, finish, path, visited) unless visited.include?(neighbor)
    end

    visited.delete(current)
    path.pop
  end
end

def adj_list(nodes)
  adj_list = Hash.new { |h, k| h[k] = [] }

  nodes.each do |(y, x), cell|
    all_neighbours = [
      [y - 1, x, :up],
      [y, x + 1, :right],
      [y + 1, x, :down],
      [y, x - 1, :left]
    ]

    neighbours = case cell
    when ">"
      all_neighbours.values_at(1)
    when "<"
      all_neighbours.values_at(3)
    when "^"
      all_neighbours.values_at(0)
    when "v"
      all_neighbours.values_at(2)
    else
      all_neighbours
    end

    neighbours.each do |ny, nx, d|
      neighbour = nodes[[ny, nx]]
      next unless neighbour

      case neighbour
      when ">"
        next unless d == :right
      when "<"
        next unless d == :left
      when "^"
        next unless d == :up
      when "v"
        next unless d == :down
      end

      adj_list[[y, x]] << [ny, nx]
    end
  end

  adj_list
end

def to_unique_id(y, x, scale)
  by = y.to_s(2).rjust(scale, "0")
  bx = x.to_s(2).rjust(scale, "0")
  "#{by}#{bx}".to_i(2)
end

map = ARGF.readlines(chomp: true).map(&:chars)
max_y = map.size - 1
scale = [max_y, map[0].size].map(&:bit_length).max
start_position = [0, map[0].index(".")]
finish_position = [max_y, map[max_y].rindex(".")]
connections = Hash.new { |h, k| h[k] = [] }
nodes = {}

map.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    next if cell == "#"

    nodes[[y, x]] = cell
  end
end


part_1_adj_list = adj_list(nodes)
part_1_graph = Graph.new(part_1_adj_list)
part_1_stack = part_1_graph.longest_path_steps_stack(start_position, finish_position)
part_1 = part_1_graph.longest_path_steps(start_position, finish_position)
puts "Part 1: #{part_1} (#{part_1_stack})"

nodes.transform_values! { "." }
part_2_adj_list = adj_list(nodes)
part_2_graph = Graph.new(part_2_adj_list)
part_2_stack = part_2_graph.longest_path_steps_stack(start_position, finish_position)
part_2 = part_2_graph.longest_path_steps(start_position, finish_position)
puts "Part 2: #{part_2} (#{part_2_stack})"
