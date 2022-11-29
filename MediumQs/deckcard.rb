class Card
  include Comparable
  attr_reader :rank, :suit

  VALUES = {'Jack' => 11, 'Queen' => 12, 'King' => 13, 'Ace' => 14}

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def value
    VALUES.fetch(rank, rank)
  end

  def to_s
    "#{rank} of #{suit}"
  end

  def <=>(other)
    value <=> other.value
  end
end

class Deck
  attr_accessor :cards

  RANKS = ((2..10).to_a + %w(Jack Queen King Ace)).freeze
  SUITS = %w(Hearts Clubs Diamonds Spades).freeze

  def initialize
    reset
  end

  def new_deck_shuffle
    RANKS.each do |rank|
      SUITS.each do |suit|
        @cards << Card.new(rank, suit)
      end
    end
    @cards.shuffle!
  end

  def draw
    reset if cards.empty?
    cards.pop
  end

  def reset
    @cards = []
    new_deck_shuffle
  end
end

deck = Deck.new
drawn = []
52.times { drawn << deck.draw }
puts drawn.count { |card| card.rank == 5 } == 4
puts drawn.count { |card| card.suit == 'Hearts' } == 13

drawn2 = []
52.times { drawn2 << deck.draw }
puts drawn != drawn2 # Almost always.
