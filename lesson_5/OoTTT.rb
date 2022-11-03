require 'pry'

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker # relies on truthiness of objects vs nil
  end

  # def count_human_marker(squares)
  #  squares.collect(&:marker).count(TTTGame::HUMAN_MARKER)
  # end

  # def count_computer_marker(squares)
  #  squares.collect(&:marker).count(TTTGame::COMPUTER_MARKER)
  # end

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.uniq.size == 1
  end

  def two_identical_markers?(squares, marker)
    markers = squares.select(&:marked?).collect(&:marker)
    markers.count(marker) == 2 && markers.uniq.size == 1
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def winning_marker # returns winning marker or nil
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def find_at_risk_square(marker)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if two_identical_markers?(squares, marker)
         return @squares.select {|k, v| line.include?(k) && v.marker == ' '}.keys.first
      end
    end
    nil
  end

  def fifth_square_marked?
    @squares[5].marker == Square::INITIAL_MARKER ? 5 : nil
  end
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength

  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
    puts ""
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end

class Square
  INITIAL_MARKER = " "
  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    @marker == INITIAL_MARKER
  end

  def marked?
    @marker != INITIAL_MARKER
  end
end

class Player
  COMPUTER_NAMES = ['R2D2', 'K.I.T.T', 'Megatron', 'Bob']
  attr_reader :score
  attr_accessor :name, :marker

  def initialize(marker, name = COMPUTER_NAMES.sample)
    @marker = marker
    @score = 0
    @name = name
  end

  def won
    @score += 1
  end

  def champion?
    @score == TTTGame::CHAMPION_WINS
  end

  def reset_score
    @score = 0
  end
end

class TTTGame
  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  CHAMPION_WINS = 3
  attr_reader :board, :human, :computer, :current_marker

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @current_marker = HUMAN_MARKER
  end

  def play
    clear
    choose_name
    choose_marker
    display_welcome_message
    main_game
    display_goodbye_message
  end

  private

  def main_game
    clear
    loop do
      display_board
      player_move
      display_champion_message
      break unless play_again?
      reset_champion
      display_play_again_message
    end
  end

  def player_move
    loop do
      loop do
        current_player_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board if human_turn?
      end
      display_result
      break if human.champion? || computer.champion?
      any_key_to_continue
      reset
      display_board
    end
  end

  def pause(num)
    sleep(num)
  end

  def choose_name
    answer = nil
    loop do 
      puts "What is your name?"
      answer = gets.chomp
      break unless answer.empty?
      puts "Please enter a valid name!"
    end
    human.name = answer
  end

  def choose_marker
    answer = nil
    loop do
      puts "Please select 'X' or 'O'"
      answer = gets.chomp.upcase
      break if ['X', 'O'].include?(answer)
      puts "Must select 'X' or 'O'!"
    end
    human.marker = answer
    computer.marker = 'O' if answer == 'X'
    computer.marker = 'X' if answer == 'O'
  end

  def any_key_to_continue
    puts "Enter any key to continue...."
    gets.chomp
  end

  def display_welcome_message
    clear
    puts "Welcome to Tic Tac Toe #{human.name}!"
    puts "Your opponent is #{computer.name}"
    puts ""
    puts "The first to #{CHAMPION_WINS} wins is the CHAMPION!"
    any_key_to_continue
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def joinor(array, char = ', ', str = 'or')
    return array[0] if array.size == 1
    return "#{array[0]} #{str} #{array[1]}" if array.size == 2
    output = ''
    array.each_with_index do |int, idx|
      if idx == (array.size - 1)
        output += "#{str} #{int}"
      else
        output += "#{int}#{char}"
      end
    end
    output
  end

  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys)}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, not a valid choice."
    end
    board[square] = human.marker
  end

  def computer_moves
    square = nil
    square = computer_offense
    square = computer_defense if !square
    square = mark_fifth_square if !square
    square = board.unmarked_keys.sample if !square
    board[square] = computer.marker
  end

  def computer_defense
    board.find_at_risk_square(HUMAN_MARKER)
  end

  def computer_offense
    board.find_at_risk_square(COMPUTER_MARKER)
  end

  def mark_fifth_square
    board.fifth_square_marked?
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def clear
    system 'clear'
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    puts "#{human.name} is #{human.marker}. #{computer.name} is #{computer.marker}"
    puts ""
    board.draw
    puts ""
  end

  def display_result
    clear_screen_and_display_board
    case board.winning_marker
    when human.marker
      human.won 
      puts "#{human.name} Won!"
    when computer.marker
      computer.won 
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
    display_scores
  end

  def display_scores
    puts "The Scoreboard is....#{human.name}: #{human.score} | #{computer.name}: #{computer.score}"
  end

  def display_champion_message
    champion = (human.champion? ? "#{human.name}" : "#{computer.name}")
    puts "The Tic Tac Toe Champion is crowned: #{champion} wins!"
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include? answer
      puts "Sorry, must be y or n!"
    end
    answer == 'y'
  end

  def reset
    board.reset
    @current_marker = HUMAN_MARKER
    clear
  end

  def reset_champion
    reset
    human.reset_score
    computer.reset_score
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ''
  end
end

game = TTTGame.new
game.play
