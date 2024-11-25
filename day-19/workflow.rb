# frozen_string_literal: true

class Workflow
  PATTERN = %r{\A(?<name>[a-z]+){(?<rules>.*)}\z}.freeze

  attr_reader :name, :rules

  def initialize(name:, rules:)
    @name = name
    @rules = rules
  end

  def self.parse(workflow)
    match_data = PATTERN.match(workflow)
    rules = match_data[:rules].split(",").map { |rule| Rule.parse(rule) }

    new(name: match_data[:name], rules: rules)
  end

  def call(ratings)
    @rules.each do |rule|
      result = rule.call(ratings)
      return result if result
    end
  end
end
