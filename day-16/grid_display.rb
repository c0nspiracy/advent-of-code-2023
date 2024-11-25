# frozen_string_literal: true

module GridDisplay
  def display
    @grid.each_with_index do |row, y|
      line = row.map.with_index do |cell, x|
        pos = Vector[y, x]
        if cell == "."
          if @energised.key?(pos)
            if @energised[pos].size > 1
              @energised[pos].size.to_s
            else
              @energised[pos].first
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

  def display_energised
    @grid.each_with_index do |row, y|
      line = row.map.with_index do |cell, x|
        pos = Vector[y, x]
        @energised.key?(pos) ? "#" : "."
      end
      puts line.join
    end
    puts
  end

  def display_beam(beam)
    @grid.each_with_index do |row, y|
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
end
