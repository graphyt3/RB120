class GuessingGame
  attr_accessor :count, :number, :guess, :win_status
  MAX_GUESSES = 7
  RANGE = 1..100

  def initialize
    @guess = nil
  end


  def play
    reset_game
    gameplay
    display_results
  end

  def display_results
    puts ''
    case win_status
    when 'lost'
      puts "You have no more guesses. You lost!"
    when 'won'
      puts 'You won!'
    end
  end

  def reset_game
    @count = MAX_GUESSES
    @number = rand(RANGE)
    @guess = nil
    @win_status = nil
  end

  def gameplay
    while count > 0
      display_guesses
      obtain_guess
      assess_guess
      break if win_status == 'won'
      self.count -= 1
    end
  end

  def assess_guess
    if guess > number
      puts "Your guess is too high."
      self.win_status = 'lost'
    elsif guess < number
      puts "Your guess is too low."
      self.win_status = 'lost'
    else
      puts "That's the number!"
      self.win_status = 'won'
    end
  end

  def obtain_guess
    loop do
      print "Enter a number between #{RANGE.first} and #{RANGE.last}: "
      self.guess = gets.chomp.to_i
      break if RANGE.include?(guess)
      print "Invalid Guess. "
    end
  end

  def display_guesses
    puts
    if count == 1
      puts "You have 1 guess remaining."
    else
      puts "You have #{count} guesses remaining."
    end
  end

end

game = GuessingGame.new
game.play