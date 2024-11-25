# frozen_string_literal: true

require_relative "./broadcast_module"
require_relative "./button_module"
require_relative "./conjunction_module"
require_relative "./flip_flop_module"

class System
  attr_reader :button_presses

  def initialize(modules:, connections:)
    @modules = modules
    @connections = connections
    @button_presses = 0
    @gh_tracking = Hash.new { |h, k| h[k] = [] }
    initialize_conjunction_modules
  end

  def push_button(debug: false)
    @button_presses += 1

    queue = @connections["button"].map do |destination|
      puts "button -low-> #{destination}" if debug
      [@modules["button"].call, destination]
    end
    pulses_fired = Hash.new(0)

    loop do
      break if queue.empty?

      pulse, destination = queue.shift
      if destination == "gh" && pulse.high?
        @gh_tracking[pulse.from] << @button_presses
        if @gh_tracking.size == 4 && @gh_tracking.all? { |_, v| v.size > 1 }
          minimum_button_presses = @gh_tracking.values.map { _2 - _1 }.reduce(:lcm)
          pulses_fired[:minimum_button_presses] = minimum_button_presses
          break
        end
      end

      pulses_fired[pulse.class] += 1
      mod = @modules[destination]
      if mod
        new_pulse = @modules[destination].call(pulse)
        if new_pulse
          @connections[destination].each do |new_destination|
            queue << [new_pulse.dup, new_destination]
            puts "#{destination} -#{new_pulse.high? ? 'high' : 'low'}-> #{new_destination}" if debug
          end
        end
      end
    end

    pulses_fired
  end

  private

  def initialize_conjunction_modules
    conjunction_modules = @modules.select { |_, v| v.is_a?(ConjunctionModule) }.keys
    @connections.each do |input, outputs|
      conjunction_outputs = outputs & conjunction_modules
      conjunction_outputs.each do |conjunction_module|
        @modules[conjunction_module].set_input(input)
      end
    end
  end
end

input = ARGF.readlines(chomp: true)

modules = {}
connections = {}

input.each do |line|
  name_and_type, destination_modules = line.split(" -> ")
  match_data = name_and_type.match(/\A(?<type>[%&]?)(?<name>[a-z]+)\z/)
  mod = if match_data["name"] == "broadcaster"
          BroadcastModule.new
        elsif match_data["type"] == "%"
          FlipFlopModule.new(name: match_data["name"])
        elsif match_data["type"] == "&"
          ConjunctionModule.new(name: match_data["name"])
        end

  modules[match_data["name"]] = mod
  connections[match_data["name"]] = destination_modules.split(", ")
end

modules["button"] = ButtonModule.new
connections["button"] = ["broadcaster"]
system = System.new(modules:, connections:)

button_presses = 0
result = {}
totals = {}

loop do
  result = system.push_button

  totals.merge!(result) { |k, v1, v2| v1 + v2 } if system.button_presses <= 1000
  if system.button_presses == 1000
    part_1 = totals.values.inject(:*)
    puts "Part 1: #{part_1}"

    break unless connections.values.any? { |v| v.include?("gh") }
  end

  break if result.key?(:minimum_button_presses)
end

puts "Part 2: #{result[:minimum_button_presses]}"
