# frozen_string_literal: true

def fits_criteria?(spring_list, size)
  spring_list.uniq.first == '#' && spring_list.size == size
end

def arrangements(spring_list, damaged_group_size)
  return 1 if spring_list.uniq == '#' && damaged_group_size == spring_list

  possibilities = [[]]
  spring_list.each do |c|
    if c == '?'
      possdup = possibilities.map(&:dup)
      possibilities.each { |a| a << '#' }
      possdup.each { |a| possibilities << (a + ['.']) }
    else
      possibilities.each { |a| a << c }
    end
  end
  possibilities.count { |arrangement| arrangement.count('#') == damaged_group_size }
end

def calculate_arrangements(spring_list, damaged_group_sizes)
  # return 1 unless spring_list.include?('?')

  groups = spring_list.slice_when { _1 != _2 }.to_a
  damaged_groups = groups.select { _1.first == '#' }
  return 1 if damaged_groups.map(&:size) == damaged_group_sizes

  chunks = spring_list.chunk { |e| e == '.' ? :_separator : true }.map(&:last)

  loop do
    wittled = false

    unless chunks.first.include?('?')
      if calculate_arrangements(chunks.first, damaged_group_sizes.slice(0, 1)) == 1
        chunks.shift
        damaged_group_sizes.shift
        wittled = true
        puts 'Wittled the first element off'
      end
    end

    unless chunks.last.include?('?')
      if calculate_arrangements(chunks.last, damaged_group_sizes.slice(-1, 1)) == 1
        chunks.pop
        damaged_group_sizes.pop
        wittled = true
        puts 'Wittled the last element off'
      end
    end

    break if chunks.empty?
    break unless wittled
  end

  puts "Remaining chunks: #{chunks.size} (#{chunks.map(&:join).join(', ')})"
  puts "Remaining groupings: #{damaged_group_sizes.join(', ')}"
  if chunks.size == damaged_group_sizes.size
    puts 'Chunk sizes match!'
    arr = chunks.zip(damaged_group_sizes).map do |chunk, size|
      res = arrangements(chunk, size)
      puts "arrangements for #{chunk}, #{size}: #{res}"
      res
    end
    arr.reduce(:*).tap { |x| puts "arrangements = #{x}" }
  else
    puts "Chunk sizes don't match!"
    binding.irb
    0
  end
end

input = ARGF.readlines(chomp: true)
arrangements = input.map do |line|
  left, right = line.split
  spring_list = left.chars
  damaged_group_sizes = right.split(',').map(&:to_i)

  calculate_arrangements(spring_list, damaged_group_sizes)
end

part1 = arrangements.sum
puts "Part 1: #{part1}"
