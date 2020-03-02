class Hangman
  '''
  Behaviors:
  - select word from dictionary
  - save and load up to 3 sessions.
  - hangman game
  '''
  @@FIGURES = File.open("figures.txt", "r").read.split("\n\n")
  @@ENTRIES = "abcdefghijklmnopqrstuvwxyz"

  def initialize
     menu
  end

  private

  def display
    puts @@FIGURES[@mistakes]
    puts "Word: " + @secret_word
    puts "Guessed letters: " +  @guessed_letters.join(" ")
  end

  def greet
    puts "Welcome to Hangman!"
    puts
  end

  def guess
    puts "Guess a letter or enter 'save' to save the current session"
    guess = gets.chomp.downcase
    until (guess.length == 1 && @@ENTRIES.include?(guess) && ! @guessed_letters.include?(guess))
      save if guess == "save"
      puts "Enter a single letter that hasn't been guessed yet."
      guess = gets.chomp.downcase
    end 

     @guessed_letters << guess
     @guessed_letters.sort!

    if @word.include?(guess)
      for char in 0...@word.length
        @secret_word[char] = guess if @word[char] == guess
      end
       @word_discovered = true if !@secret_word.include?("_")   
    else
      @mistakes += 1
    end
  end

  def load
    puts "Let's load a session"
    
    Dir.mkdir("sessions") unless Dir.exist?("sessions")
    sessions = Dir.children("sessions")

    if sessions.length == 0
      puts "There aren't any saved sessions. Press enter to start a new game"
      gets
      play
    else
      puts "Choose a session by name: " + sessions.join(", ")
      session = gets.chomp.downcase
      until sessions.include?(session)
        puts "Enter a valid session"
        session = gets.chomp.downcase
      end

      session_data = Marshal::load(File.open("sessions/" + session, "r").read)
      marshal_load session_data

      puts "Session loaded. Press enter to start"
      gets
      play true
    end
  end

  def marshal_dump
    [@word, @secret_word, @guessed_letters, @mistakes,  @word_discovered]
  end

  def marshal_load array
    @word, @secret_word, @guessed_letters, @mistakes, @word_discovered = array
  end

  def menu
    greet
    puts "Would you like to play a new game or load a saved session? (new/load)"
    answer = gets.chomp.downcase
    until answer == "new" || answer == "load"
      puts "Enter 'new' or 'load'"
      answer = gets.chomp.downcase
    end

    answer == "new"? play : load
  end

  def play loaded=false

    unless loaded
      @guessed_letters = []
      @mistakes = 0
      @word_discovered = false
      select_word
    end

    system("clear") || system("cls")

    until @mistakes >= 6 || @word_discovered
      display
      guess
      system("clear") || system("cls")
    end

    display
    result
    play_again
  end

  def play_again
    puts "Play again? (y/n)"
    answer = gets.chomp.downcase
    until answer == "y" || answer == "n"
      puts "y or n"
      answer = gets.chomp.downcase
    end

    if answer == "y"
      play
    else
      puts "Bye"
    end
  end

  def result
    puts  @word_discovered? "You win!" : "You lost!"
  end

  def save
    puts "Let's save the session"
    
    Dir.mkdir("sessions") unless Dir.exist?("sessions")
    sessions = Dir.children("sessions")

    if sessions.length == 3
      puts "You must delete one of the following sessions to save your session"
      puts sessions.join(", ")
      puts "Enter 'cancel' or the name of the session to delete"
      answer = gets.chomp.downcase
      until answer == "cancel" || sessions.include?(answer)
        puts "Enter 'cancel' or the name of the session to delete"
        answer = gets.chomp.downcase
      end
      if answer == "cancel"
        puts "Press enter to return to guessing"
        gets
        return
      else
        File.delete("sessions/" + answer)
      end
    end

    puts "Now enter an alphanumerical session name ('_' includeded) of up to 20 characters"
    session = gets.chomp.downcase
    until session.match(/\W+/).nil? && session.length > 0 && session.length <= 20 && session != "cancel"
      puts "Now enter an alphanumerical session name ('_' includeded) of up to 20 characters"
      session = gets.chomp.downcase
    end

    File.open("sessions/" + session, "w") do |file|
      file.puts Marshal::dump(marshal_dump)
    end

    puts "Session saved. Come again!"
    exit
  end

  def select_word
      options = File.open("5desk.txt", "r").read.split().select {|word| word.length >= 5 && word.length <= 12}
      @word = options.sample
      @secret_word = "_" * @word.length
  end

end

Hangman.new

