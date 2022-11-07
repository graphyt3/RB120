module Displayable
  def prompt(msg)
    puts "==> #{msg}"
  end

  def single_spacer
    puts ''
  end

  def clear_screen
    system 'clear'
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

  def hit
  end

  def stay
  end

  def busted?
    @hand_score > Deck::HIGH
  end

  def update_hand_total_score
    values = @current_hand.map { |card| card.face } # extract all card values & store into new array
    sum = 0
    values.each do |face|
      if 'JQK'.include?(face)
        sum += 10
      elsif face == 'A'
        sum += 11
      else
        sum += face.to_i
      end
    end
    sum = total_aces(values, sum)
    @hand_score = sum
    # definitely looks like we need to know about "cards" to produce some total
  end

  def total_aces(faces, total)
    number_of_aces = faces.select { |face| face == 'A' }
    number_of_aces.count.times do
      total -= 10 if total > 21
    end
    total
  end
end

class Player < Participant
  def initialize
    super
    # what would the "data" or "states" of a Player object entail?
    # maybe cards? a name?
  end

 
end

class Dealer < Participant
  attr_accessor :turn
  
  def initialize
    super
    @turn = 'no'
  end

  def deal
    # does the dealer or the deck deal?
  end

end

class Deck
  FACES = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  SUITS = %w[Hearts Diamonds Clubs Spades].freeze
  HIGH = 21
  DEALER_BREAK = 17

  attr_accessor :cards
  
  def initialize
    @cards = []
    new_deck_shuffle
  end

  def new_deck_shuffle
    FACES.each do |faces|
      SUITS.each do |suits|
        @cards << Card.new(faces, suits)
      end
    end
    @cards.shuffle!
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
  attr_accessor :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    welcome_message
    deal_cards
    #loop do
      calculate_current_hand
      #break if @player.hand_score == Deck::HIGH || @dealer.hand_score == Deck::HIGH
      show_cards
      player_turn
      dealer_turn
      show_result
    #end
    #goodbye_message
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
    2.times do
      @player.current_hand << @deck.cards.pop
      @dealer.current_hand << @deck.cards.pop
    end
  end

  def show_cards
    clear_screen
    if dealer.turn == 'yes'
      prompt("Dealer has: #{cards_in_hand(@dealer.current_hand)} for a total of #{@dealer.hand_score}")
    else
      prompt("Dealer has: #{@dealer.current_hand[0].face} of #{@dealer.current_hand[0].suit}, and unknown card")
    end
    single_spacer
    prompt("You have: #{cards_in_hand(@player.current_hand)} for a total of #{@player.hand_score}")
  end

  def cards_in_hand(participant_hand)
    cards_listed = participant_hand.map { |card| "#{card.face} of #{card.suit}" }
    cards_listed.join(', ')
  end

  def calculate_current_hand
    @player.update_hand_total_score
    @dealer.update_hand_total_score
    # needs to check if either hand == 21!
  end

  def dealt_21?(participant_hand)
    participant_hand == Deck::HIGH
  end

  def player_turn
    loop do
      
      loop do

      end
      
    end
  end

  def dealer_turn

  end

  def show_result

  end

  def play_again?
    prompt("Would you like to play again? (y/n)")
    answer = gets.chomp
    answer.downcase.start_with?('y') 
  end

  def goodbye_message
    clear_screen
    prompt("Thanks for playing 21!")
  end
end

Game.new.start