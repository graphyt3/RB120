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
  MAX_SCORE = 3
  attr_accessor :move, :name, :score, :move_history

  def initialize
    set_name
    @score = 0
    @move_history = []
    # maybe a "name"? what about a "move"?
  end

  def choice_conversion(input)
    case input
    when 'rock' then Rock.new(input)
    when 'scissors' then Scissors.new(input)
    when 'paper' then Paper.new(input)
    when 'lizard' then Lizard.new(input)
    when 'spock' then Spock.new(input)
    end
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
      puts "Please choose rock, paper, scissors, lizard, or spock:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = choice_conversion(choice)
    move_history << move
  end
end

class Computer < Player
  def set_name
    self.name = ["R2D2", "K.I.T.T.", "Megatron", "Wall-E"].sample
  end

  def choose
    self.move = choice_conversion(Move::VALUES.sample)
    move_history << move
  end

  def computer_conversion(name)
    case name
    when "R2D2" then R2D2.new(name)
    when "K.I.T.T." then KITT.new(name)
    when "Megatron" then Megatron.new(name)
    when "Wall-E" then WALLE.new(name)
    end
  end
end

class R2D2 < Computer

end

class KITT < Computer

end

class Megatron < Computer

end

class WALLE < Computer

end

class Move
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']

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

  def spock?
    @value == 'spock'
  end

  def lizard?
    @value == 'lizard'
  end

  def to_s
    @value
  end
end

class Rock < Move
  def >(other_move)
    other_move.scissors? || other_move.lizard?
  end
end

class Scissors < Move
  def >(other_move)
    other_move.lizard? || other_move.paper?
  end
end

class Paper < Move
  def >(other_move)
    other_move.rock? || other_move.spock?
  end
end

class Lizard < Move
  def >(other_move)
    other_move.paper? || other_move.spock?
  end
end

class Spock < Move
  def >(other_move)
    other_move.rock? || other_move.scissors?
  end
end

# Game Orchestration Engine
class RPSGame
  attr_accessor :human, :computer, :champion

  def initialize
    clear_screen
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    clear_screen
    puts "Welcome to Rock, Paper, Scissors, Lizard, & Spock - The first to win #{Player::MAX_SCORE} games is the champion!"
    puts "-------------------------------------------------------------------------------------------"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors! Good-Bye!"
  end

  def display_choices
    clear_screen
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def clear_screen
    system('clear')
  end

  def pause(time)
    sleep(time)
  end

  def display_winner
    if human.move > (computer.move)
      human.score += 1
      puts "#{human.name} won!"
    elsif human.move.to_s == computer.move.to_s
      puts "It's a tie!"
    else
      computer.score += 1
      puts "#{computer.name} won!"
    end
  end

  def display_score
    puts ""
    puts "#{human.name} has won #{human.score} times | #{computer.name} has won #{computer.score} times"
    puts ""
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

  def display_history
    puts " Round |#{human.name.center(15)}|#{computer.name.center(15)}"
    puts "-" * 37
    counter = 0
    while counter < human.move_history.size
      index = counter.to_s
      human_move = human.move_history[counter].to_s
      computer_move = computer.move_history[counter].to_s
      puts "#{index.center(7)}|#{human_move.center(15)}|#{computer_move.center(15)}"
      counter += 1
    end
    puts ""
  end

  def max_score?
    human.score == Player::MAX_SCORE || computer.score == Player::MAX_SCORE
  end

  def reset_scores
    human.score = 0
    computer.score = 0
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
        display_history
        break if max_score?
      end
      break unless play_again?
      reset_scores
    end
    display_goodbye_message
  end
end

RPSGame.new.play
