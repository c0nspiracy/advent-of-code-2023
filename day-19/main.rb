# frozen_string_literal: true

require_relative "./workflows"
require_relative "./workflow"
require_relative "./rule"
require_relative "./null_rule"

input = ARGF.read
workflows_input, ratings_input = input.split("\n\n").map(&:split)

workflows = workflows_input.each_with_object({}) do |workflow_input, memo|
  workflow = Workflow.parse(workflow_input)
  memo[workflow.name] = workflow
end

ratings = ratings_input.map do |rating_input|
  x, m, a, s = rating_input.scan(/\A{x=(\d+),m=(\d+),a=(\d+),s=(\d+)}\z/).first.map(&:to_i)
  { "x" => x, "m" => m, "a" => a, "s" => s }
end

accepted_ratings = ratings.select do |rating|
  workflow_name = "in"
  loop do
    break if workflow_name == "A" || workflow_name == "R"

    workflow_name = workflows[workflow_name].call(rating)
  end

  workflow_name == "A"
end

part_1 = accepted_ratings.flat_map(&:values).sum
puts "Part 1: #{part_1}"

workflows_obj = Workflows.new(workflows: workflows)
paths = workflows_obj.descend

paths = paths.each_slice(2).to_a

accepted_paths = paths.select { |_rules, result| result == :accepted }.map(&:first)

part_2 = accepted_paths.sum do |rules|
  amounts = {
    "x" => [1, 4000],
    "m" => [1, 4000],
    "a" => [1, 4000],
    "s" => [1, 4000]
  }

  rules.each do |rule|
    v = rule.value
    case rule.operator
    when "<"
      v -= 1
      amounts[rule.category][1] = [v, amounts[rule.category][1]].min
    when "<="
      amounts[rule.category][1] = [v, amounts[rule.category][1]].min
    when ">"
      v += 1
      amounts[rule.category][0] = [v, amounts[rule.category][0]].max
    when ">="
      amounts[rule.category][0] = [v, amounts[rule.category][0]].max
    end
  end

  puts rules.map(&:to_s).join(", ")
  puts amounts
  puts
  amounts.values.map { |a, b| (b - a) + 1 }.inject(:*)
end
puts "Part 2: #{part_2}"
