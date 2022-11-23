class GuessingGame
  attr_accessor :count, :number
  MAX_GUESSES = 7
  RANGE = 1..100

  def initialize

  end


  def play
    reset_game
    gameplay
  end

  def reset_game
    @count = MAX_GUESSES
    @number = rand(RANGE)
  end

  def gameplay
    while count > 0
      display_guesses
      obtain_guess
      self.count -= 1
    end
  end

  def obtain_guess
    answer = nil
    loop do
      puts "Enter a number between #{RANGE.first} and #{RANGE.last}"
      answer = gets.chomp.to_i
      break if RANGE.include?(answer)
      puts "Invalid Guess."
    end
    answer
  end

  def display_guesses
    puts "You have #{count} guesses remaining."
  end

end

game = GuessingGame.new
game.play