class Player
  MAX_SCORE = 3
  attr_accessor :move, :name, :score, :move_history

  def initialize
    set_name
    @score = 0
    @move_history = []
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
end

class Human < Player
  def choose
    choice = nil
    loop do
      puts ""
      puts "-" * 93
      puts "Please choose rock, paper, scissors, lizard, or spock:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = choice_conversion(choice)
    move_history << move
  end

  private

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
end

class Computer < Player
  def choose(_)
    self.move = choice_conversion(Move::VALUES.sample)
    move_history << move
  end

  private

  def set_name
    self.name = ["R2D2", "K.I.T.T.", "Megatron", "Wall-E"].sample
  end
end

class R2D2 < Computer
  def choose(*) # high tendency to choose scissors 70% of the time!
    number = pick_number
    self.move = if number <= 7
                  choice_conversion('scissors')
                else
                  choice_conversion(['rock', 'paper', 'lizard', 'spock'].sample)
                end
    move_history << move
  end

  private

  def set_name
    self.name = "R2D2"
  end

  def pick_number
    rand(1..10)
  end
end

class KITT < Computer
  private

  def set_name
    self.name = "K.I.T.T."
  end
  # randomly select moves!
end

class Megatron < Computer
  def choose(other_move) # always chooses winning move!
    self.move = select_winner(other_move)
    move_history << move
  end

  private

  def set_name
    self.name = "Megatron"
  end

  def select_winner(input)
    move = nil
    loop do
      move = choice_conversion(Move::VALUES.sample)
      break if move > (input)
    end
    move
  end
end

class WALLE < Computer
  def choose(*) # always chooses paper to recycle!
    self.move = choice_conversion('paper')
    move_history << move
  end

  private

  def set_name
    self.name = "Wall-E"
  end
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
    @computer = computer_generator
  end

  def play
    display_opponent
    display_welcome_message
    display_rules
    loop do
      gameplay_loop
      break unless play_again?
      reset_scores
    end
    display_goodbye_message
  end

  private

  def gameplay_loop
    loop do
      human.choose
      computer.choose(human.move)
      display_choices
      display_winner
      display_history
      display_score
      break if max_score?
    end
  end

  def computer_generator
    num = rand(1..4)
    case num
    when 1 then Megatron.new
    when 2 then R2D2.new
    when 3 then KITT.new
    when 4 then WALLE.new
    end
  end

  def display_welcome_message
    clear_screen
    puts "Welcome to Rock, Paper, Scissors, Lizard, & Spock."
    puts "The first to win #{Player::MAX_SCORE} games is the champion!"
  end

  def display_rules
    puts ""
    puts "RULES OF THE GAME:"
    puts ""
    puts "Rock BREAKS Scissors and CRUSHES Lizard"
    puts "Paper COVERS Rock and DISPROVES Spock"
    puts "Scissors CUTS Paper and DECAPITATES Lizard"
    puts "Lizard POISONS Spock and EATS Paper"
    puts "Spock SMASHES Scissors and VAPORIZES Rock"
  end

  def display_goodbye_message
    clear_screen
    puts "Thanks for playing Rock, Paper, Scissors! Good-Bye!"
  end

  def display_choices
    clear_screen
    puts "#{human.name} chose #{human.move}!"
    pause(1.25)
    puts "#{computer.name} chose #{computer.move}!"
    pause(1.25)
    puts ""
  end

  def display_opponent
    puts ""
    puts "Hello #{human.name}. You'll be facing #{computer.name} today...."
    pause(4)
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
    puts ""
    puts " Round |#{human.name.center(15)}|#{computer.name.center(15)}"
    puts "-" * 37

    human.move_history.each_with_index do |mv, index|
      round = (index + 1).to_s
      computer_mv = computer.move_history[index].to_s
      puts "#{round.center(7)}|#{mv.to_s.center(15)}|#{computer_mv.center(15)}"
    end
    # counter = 0
    # while counter < human.move_history.size
    #  index = (counter + 1).to_s
    #  human_mv = human.move_history[counter].to_s
    #  computer_mv = computer.move_history[counter].to_s
    #  puts "#{index.center(7)}|#{human_mv.center(15)}|#{computer_mv.center(15)}"
    #  counter += 1
    # end
  end

  def max_score?
    human.score == Player::MAX_SCORE || computer.score == Player::MAX_SCORE
  end

  def reset_scores
    human.score = 0
    computer.score = 0
    human.move_history = []
    computer.move_history = []
    @computer = computer_generator
  end
end

RPSGame.new.play
