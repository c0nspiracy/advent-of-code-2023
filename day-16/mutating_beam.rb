# frozen_string_literal: true

require "matrix"
require "active_support/core_ext/object/deep_dup"

class MutatingBeam
  attr_reader :direction, :position

  def initialize(position: Vector[0, 0], direction: Vector[0, 1])#, visited: Hash.new { |h, k| h[k] = Set.new }, splits: Set.new)
    @position = position
    @direction = direction
    # @visited = visited
    # @splits = splits
    @new_beam = true
  end

  def new_beam?
    @new_beam
  end

  def advance
    @new_beam = false
    #@visited[@position] << @direction
    @position += @direction
  end

  def reflect(mirror)
    @direction = case mirror
                 when "/"
                   case d
                   when ">" then Vector[-1, 0]
                   when "<" then Vector[1, 0]
                   when "^" then Vector[0, 1]
                   when "v" then Vector[0, -1]
                   end
                 when "\\"
                   case d
                   when ">" then Vector[1, 0]
                   when "<" then Vector[-1, 0]
                   when "^" then Vector[0, -1]
                   when "v" then Vector[0, 1]
                   end
                 end
    self
  end

  # def looped?
  #   @visited[@position].include?(@direction)
  # end

  def debug_position(position)
    return "*" if position == @position

    dirs = @visited[position]
    case dirs.size
    when 0 then false
    when 1 then d(dirs.first)
    when 2 then dirs.size
    end
  end

  def split(splitter)
    case splitter
    when "-"
      case d
      when ">", "<"
        self
      when "^", "v"
        # if @splits.include?(@position)
        #   puts "Not splitting at #{@position}, this beam has already split here previously"
        #   []
        # else
          # @splits << @position
          @new_beam = true
          @direction = Vector[0, -1]
          [self, split_self(Vector[0, 1])]
        # end
      end
    when "|"
      case d
      when ">", "<"
        # if @splits.include?(@position)
        #   puts "Not splitting at #{@position}, this beam has already split here previously"
        #   []
        # else
          # @splits << @position
          @new_beam = true
          @direction = Vector[-1, 0]
          [self, split_self(Vector[1, 0])]
        # end
      when "^", "v"
        self
      end
    end
  end

  def d(direction = @direction)
    case direction
    when Vector[0, 1] then ">"
    when Vector[0, -1] then "<"
    when Vector[1, 0] then "v"
    when Vector[-1, 0] then "^"
    else raise "Unknown direction: #{direction}"
    end
  end

  def split_self(new_direction)
    self.class.new(
      position: @position.dup,
      direction: new_direction.dup,
      # visited: @visited.deep_dup,
      # splits: @splits.deep_dup
    )
  end
end
