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

  def pause(num)
    sleep(num)
  end

  def press_enter_to_continue
    prompt("Press enter to continue")
    gets
  end
end

class Participant
  attr_accessor :total_wins, :hand_score, :current_hand

  # what goes in here? all the redundant behaviors from Player and Dealer?
  def initialize
    @total_wins = 0
    @hand_score = 0
    @current_hand = []
  end

  def busted?
    @hand_score > Deck::HIGH
  end

  def update_hand_total_score
    values = @current_hand.map(&:face) # { |card| card.face } extract all card values & store into new array
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
  attr_accessor :choice

  def initialize
    super
    @choice = ''
  end
end

class Dealer < Participant
  attr_accessor :turn, :win_status

  def initialize
    super
    @win_status = 'no'
    @turn = 'no'
  end
end

class Deck
  FACES = %w(2 3 4 5 6 7 8 9 10 J Q K A).freeze
  SUITS = %w(Hearts Diamonds Clubs Spades).freeze
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
end

class Card
  attr_accessor :face, :suit

  def initialize(face, suit)
    @face = face
    @suit = suit
  end
end

class Game
  include Displayable
  attr_accessor :deck, :player, :dealer

  MAX_WINS = 3

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    loop do
      welcome_message
      main_game_loop
      break unless play_again?
      game_reset
    end
    goodbye_message
  end

  private

  def main_game_loop
    loop do
      deal_cards
      player_turn
      dealer_turn unless dealt_21?(@player)
      show_result
      break if champion?
      press_enter_to_continue
      reset_hands
    end
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
    prompt("The first to win #{MAX_WINS} rounds is the winner!")
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
    if @dealer.turn == 'yes'
      prompt("Dealer has: #{cards_in_hand(@dealer.current_hand)} for a total of #{@dealer.hand_score}")
    else
      prompt("Dealer has: #{@dealer.current_hand[0].face} of #{@dealer.current_hand[0].suit}, and unknown card")
    end
    single_spacer
    prompt("You have: #{cards_in_hand(@player.current_hand)} for a total of #{@player.hand_score}")
    single_spacer
    puts "==============================================="
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

  def dealt_21?(participant)
    participant.hand_score == Deck::HIGH
  end

  def player_turn
    calculate_current_hand
    loop do
      break if dealt_21?(@player)
      show_cards
      @player.choice = player_choice
      break unless @player.choice.start_with?('h')
      @player.current_hand << @deck.cards.pop # player hits
      calculate_current_hand
      if @player.busted?
        @dealer.win_status = 'yes'
        break
      end
    end
  end

  def player_choice
    answer = nil
    loop do
      prompt("Your turn: (H)it or (S)tay?")
      answer = gets.chomp.downcase
      break if answer.start_with?('h') || answer.start_with?('s')
      prompt("Please enter 'h' or 's'")
    end
    answer
  end

  def dealer_turn
    @dealer.turn = 'yes' # to reveal dealer's hand
    loop do
      break if @dealer.win_status == 'yes' ||
               @dealer.hand_score >= Deck::DEALER_BREAK ||
               @dealer.busted?
      @dealer.current_hand << @deck.cards.pop # dealer hits
      calculate_current_hand
    end
  end

  def show_result
    show_cards
    show_who_won
    show_total_wins
  end

  def show_who_won
    if @player.hand_score > @dealer.hand_score && !@player.busted?
      @player.total_wins += 1
      prompt('You won!')
    elsif @dealer.hand_score > @player.hand_score && !@dealer.busted?
      @dealer.total_wins += 1
      prompt('Dealer won!')
    elsif @player.hand_score == @dealer.hand_score
      prompt("It's a push!")
    elsif @dealer.busted? # computer busted?
      @player.total_wins += 1
      prompt('Dealer BUSTED - You won!')
    else
      @dealer.total_wins += 1
      prompt('You BUSTED - Dealer won!') # player busted?
    end
  end

  def show_total_wins
    single_spacer
    prompt("Grand Total Wins:: Player: #{@player.total_wins} | Dealer: #{@dealer.total_wins}")
  end

  def champion?
    @player.total_wins == MAX_WINS || @dealer.total_wins == MAX_WINS
  end

  def play_again?
    prompt("Would you like to play again? (y/n)")
    answer = gets.chomp
    answer.downcase.start_with?('y')
  end

  def reset_hands
    @player.current_hand = []
    @dealer.current_hand = []
    @dealer.win_status = 'no'
    @dealer.turn = 'no'
  end

  def game_reset
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def goodbye_message
    clear_screen
    prompt("Thanks for playing 21!")
  end
end

Game.new.start
