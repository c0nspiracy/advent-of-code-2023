# frozen_string_literal: true

class HandWithJokers < Hand
  NEW_CARD_RANKS = %w[A K Q T 9 8 7 6 5 4 3 2 J].freeze

  def type
    @type ||= begin
                types = joker_signatures.map do |new_hand|
                  signature = new_hand.tally.values.sort.reverse
                  type_for(signature)
                end
                types.min_by { |type| HAND_RANKS.index(type) }
              end
  end

  def type_for(signature)
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

  def joker_signatures
    return [@cards] unless @cards.include?("J")

    permutations = non_joker_cards.repeated_permutation(joker_indices.size)

    permutations.map do |permutation|
      new_hand = @cards.dup
      permutation.each_with_index do |card, index|
        new_hand[joker_indices[index]] = card
      end
      new_hand
    end
  end

  def non_joker_cards
    c = @cards.uniq - ["J"]
    c.empty? ? ["A"] : c
  end

  def joker_indices
    @cards.each_with_index.select { |card, _| card == "J" }.map(&:last)
  end

  def card_ranks
    @cards.map { |card| NEW_CARD_RANKS.index(card) }
  end
end
