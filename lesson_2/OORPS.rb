=begin
Nouns: player, move, rule
Verbs: choose, compare

Player
 - choose
Move
Rule

- compare
=end

class Player
  MAX_SCORE = 10
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
    # maybe a "name"? what about a "move"?
  end

  def human?
    @player_type == :human
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What is your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, or scissors:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ["Joss", "Sam", "Shams"].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class Move
  VALUES = ['rock', 'paper', 'scissors']

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def >(other_move)
    (rock? && other_move.scissors?) ||
      (paper? && other_move.rock?) ||
      (scissors? && other_move.paper?)
  end

  def <(other_move)
    (rock? && other_move.paper?) ||
      (paper? && other_move.scissors?) ||
      (rock? && other_move.rock?)
  end

  def to_s
    @value
  end
end

# Game Orchestration Engine
class RPSGame
  attr_accessor :human, :computer, :champion

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors - The first to win 10 games is the champion!"
    puts "-----------------------------------------------------------------------------"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors! Good-Bye!"
  end

  def display_choices
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_winner
    if human.move > computer.move
      human.score += 1
      puts "#{human.name} won!"
    elsif human.move < computer.move
      computer.score += 1
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def display_score
    puts "#{human.name} has won #{human.score} times | #{computer.name} has won #{computer.score} times"
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must be y or n"
    end

    return true if answer == 'y'
    return false if answer == 'n'
  end

  def max_score?
    human.score == Player::MAX_SCORE || computer.score == Player::MAX_SCORE
  end

  def play
    display_welcome_message
    loop do
      loop do
        human.choose
        computer.choose
        display_choices
        display_winner
        display_score
        break if max_score?
      end
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play