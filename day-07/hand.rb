# frozen_string_literal: true

class Hand
  HAND_RANKS = %i[five_of_a_kind four_of_a_kind full_house three_of_a_kind two_pair one_pair high_card].freeze
  CARD_RANKS = %w[A K Q J T 9 8 7 6 5 4 3 2].freeze

  attr_reader :bid

  def initialize(cards, bid)
    @cards = cards
    @bid = bid
  end

  def to_s
    "#{@cards.join} #{type.to_s.ljust(15)}"
  end

  def <=>(other)
    rank <=> other.rank
  end

  def rank
    [HAND_RANKS.index(type), *card_ranks]
  end

  def type
    case signature
    in [5] then :five_of_a_kind
    in [4, 1] then :four_of_a_kind
    in [3, 2] then :full_house
    in [3, 1, 1] then :three_of_a_kind
    in [2, 2, 1] then :two_pair
    in [_, _, _, _] then :one_pair
    in [_, _, _, _, _] then :high_card
    end
  end

  private

  def card_ranks
    @cards.map { |card| CARD_RANKS.index(card) }
  end

  def signature
    @cards.tally.values.sort.reverse
  end
end
