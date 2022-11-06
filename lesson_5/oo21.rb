module Displayable
  def prompt(msg)
    puts "==> #{msg}"
  end

  def clear_screen
    system 'clear'
  end
end

class Player < Participant
  def initialize
    # what would the "data" or "states" of a Player object entail?
    # maybe cards? a name?
  end

  def hit
  end

  def stay
  end

  def busted?
  end

  def total
    # definitely looks like we need to know about "cards" to produce some total
  end
end

class Dealer < Participant
  def initialize
    # seems like very similar to Player... do we even need this?
  end

  def deal
    # does the dealer or the deck deal?
  end

  def hit
  end

  def stay
  end

  def busted?
  end

  def total
  end
end

class Participant
  attr_accessor :total_wins, :hand_score, :current_hand

  MAX_WINS = 3
  # what goes in here? all the redundant behaviors from Player and Dealer?
  def initialize
    @total_wins = 0
    @hand_score = 0
    @current_hand = []
  end

end

class Deck
  FACES = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  SUITS = %w[Hearts Diamonds Clubs Spades].freeze
  HIGH = 21
  DEALER_BREAK = 17
  
  
  def initialize
    @deck = []
    new_deck_shuffle
    # obviously, we need some data structure to keep track of cards
    # array, hash, something else?
  end

  def new_deck_shuffle
    FACES.each do |faces|
      SUITS.each do |suits|
        temp_holder = Card.new(faces, suits)
        @deck << temp_holder
        # temp_holder = []
        # temp_holder << suits
        # temp_holder << faces
        # temp_holder << "#{faces} of #{suits}" # Name of card to be seen on screen
        # @deck << temp_holder
      end
    end
    @deck.shuffle!
  end

  def deal
    # does the dealer or the deck deal?
  end
end

class Card
  attr_accessor :face, :suit

  def initialize(face, suit)
    @face = face
    @suit = suit
    # what are the "states" of a card?
  end


end

class Game
  include Displayable
  attr_accessor :deck

  def initialize
    @deck = Deck.new
  end

  def start
    welcome_message
    p @deck
    deal_cards
    show_initial_cards
    player_turn
    dealer_turn
    show_result
  end

  def welcome_message
    clear_screen
    prompt('Welcome to Twenty-One!')
    prompt('=========================================')
    prompt('Instructions to play:')
    prompt('You will be playing against the computer.')
    prompt('The goal is to get as close to 21 without going over.')
    prompt('Numbered cards are their own value. (I.E 2 = 2).')
    prompt('(J)acks, (Q)ueens, (K)ings are worth 10 each.')
    prompt('(A)ces are worth 1 or 11.')
    prompt("The first to win #{Participant::MAX_WINS} rounds is the winner!")
    prompt('=========================================')
    prompt('Press Enter to Start!')
    gets
  end

  def deal_cards

  end

  def show_initial_cards

  end

  def player_turn

  end

  def dealer_turn

  end

  def show_result

  end
end

Game.new.start