# frozen_string_literal: true

class Rule
  CATEGORY_PATTERN = %r{(?<category>[xmas])}.freeze
  CONDITION_PATTERN = %r{(?<operator>[<>])(?<value>\d+)}.freeze
  DESTINATION_PATTERN = %r{(?<destination>A|R|[a-z]+)}.freeze

  PATTERN = %r{\A(#{CATEGORY_PATTERN}#{CONDITION_PATTERN}:)?#{DESTINATION_PATTERN}\z}.freeze

  TERMINAL_PATTERN = %r{\A#{DESTINATION_PATTERN}\z}.freeze

  attr_reader :category, :operator, :value, :destination

  def initialize(category:, operator:, value:, destination:)
    @category = category
    @operator = operator
    @value = value.to_i
    @destination = destination
  end

  def invert!
    self.class.new(
      category: @category,
      operator: inverse_operator,
      value: @value,
      destination: @destination
    )
  end

  def terminal?
    accepted? || rejected?
  end

  def conditional?
    true
  end

  def accepted?
    @destination == "A"
  end

  def rejected?
    @destination == "R"
  end

  def to_s
    "(#{@category} #{@operator} #{@value})" # --> #{@destination})"
  end
  alias_method :inspect, :to_s

  def self.parse(rule)
    match_data = PATTERN.match(rule)

    case match_data
    in nil
      raise "Parsing failed for rule #{rule}"
    in { category: nil, destination: }
      NullRule.new(destination:)
    else
      new(**match_data.named_captures.transform_keys(&:to_sym))
    end
  end

  def call(ratings)
    ratings[@category].send(@operator, @value) ? @destination : false
  end

  private

  def inverse_operator
    case @operator
    when ">" then "<="
    when "<" then ">="
    end
  end
end
