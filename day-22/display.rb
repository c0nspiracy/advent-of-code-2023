# frozen_string_literal: true

class Display
  def initialize(bricks)
    @bricks = bricks
  end

  def self.render_both(bricks)
    new(bricks).render_both
  end

  def render_both
    x_output = plot(axis: "x")
    y_output = plot(axis: "y")

    max_length_x = x_output.map(&:length).max
    x_output.map! { _1.ljust(max_length_x, " ") }

    max_length_y = y_output.map(&:length).max
    y_output.map! { _1.ljust(max_length_y, " ") }

    x_output.zip(y_output).each do |left, right|
      puts [left, right].join("     ")
    end
    puts
  end

  def render(axis:)
    plot(axis:).each do |line|
      puts line
    end
    puts
  end

  private

  def plot(axis:)
    v_size = send("#{axis}_size")
    v_range = send("min_#{axis}")..send("max_#{axis}")

    output = []
    output << axis.center(v_size * label_width)
    output << v_range.to_a.map { _1.to_s.center(label_width) }.join

    max_z.downto(1).each do |z|
      line = v_range.map do |v|
        cube = axis == "x" ? Vector[v, nil, z] : Vector[nil, v, z]
        bricks_in_position = @bricks.values.select { |brick| brick.cover?(cube) }

        if bricks_in_position.size > 1
          "?" * label_width
        elsif bricks_in_position.size == 1
          bricks_in_position[0].name.center(label_width, "_")
        else
          "." * label_width
        end
      end

      output << "#{line.join} #{z} #{z == z_mid ? 'z' : ' '}"
    end

    output << (("-" * v_size * label_width) + " 0")
    output
  end

  def label_width
    @label_width ||= @bricks.keys.max_by(&:length).length
  end

  def x_size = (max_x - min_x) + 1
  def y_size = (max_y - min_y) + 1
  def z_mid = max_z.fdiv(2).ceil

  def min_x = mins[0]
  def min_y = mins[1]
  def min_z = mins[2]

  def max_x = maxes[0]
  def max_y = maxes[1]
  def max_z = maxes[2]

  def mins
    @mins ||= minmaxes[0].map(&:min)
  end

  def maxes
    @maxes ||= minmaxes[1].map(&:max)
  end

  def minmaxes
    @bricks.values.map(&:bounds).transpose.map(&:transpose).transpose
  end
end
