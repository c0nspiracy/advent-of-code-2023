# frozen_string_literal: true

class Workflows
  def initialize(workflows:)
    @workflows = workflows
  end

  def descend(name = "in", rules = [])
    @workflows[name].rules.flat_map do |rule|
      destination = rule.destination

      result = []
      result << if rule.conditional?
        [*rules, rule]
      else
        [*rules]
      end
      if rule.accepted?
        result << :accepted
      elsif rule.rejected?
        result << :rejected
      else
        new_rules = if rule.conditional?
          [*rules, rule]
        else
          [*rules]
        end
        result = descend(destination, new_rules)
      end
      rules << rule.invert! if rule.conditional?
      result
    end
  end
end
