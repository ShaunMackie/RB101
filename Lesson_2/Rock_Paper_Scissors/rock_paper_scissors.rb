require 'yaml'
MESSAGES = YAML.load_file('rock_paper_scissors.yml')

VALID_CHOICES = { 'r': 'rock',
                  'p': 'paper',
                  'sc': 'scissors',
                  'l': 'lizard',
                  'sp': 'spock' }

def prompt(message)
  puts("=>#{message}")
end

def messages(message)
  prompt(MESSAGES[message])
end

def clear
  system('clear') || system('cls')
end

def line_break
  puts "\n"
end

def display_welcome_message
  messages('welcome')
  messages('rules')
  line_break
end

def win?(first, second)
  (first == 'rock' && (second == 'scissors' || second == 'lizard')) ||
    (first == 'paper' && (second == 'rock' || second == 'spock')) ||
    (first == 'scissors' && (second == 'paper' || second == 'lizard')) ||
    (first == 'lizard' && (second == 'spock' || second == 'paper')) ||
    (first == 'spock' && (second == 'scissors' || second == 'rock'))
end

def round_winner(player, computer)
  winner = nil

  if win?(player, computer)
    "player"
  elsif win?(computer, player)
    "computer"
  else
    winner
  end
end

def display_result(winner)
  if winner == "player"
    prompt("=>You won!")
  elsif winner == "computer"
    prompt("=>Computer won!")
  else
    prompt("=>It's a tie!")
  end

  line_break
end

def user_choice
  choice = nil
  loop do
    messages('choices')
    choice = gets.chomp.downcase.to_sym
    if VALID_CHOICES.include?(choice)
      return choice = VALID_CHOICES[choice]
    else
      messages('invalid_choice')
      line_break
    end
  end
end

def display_choices(choice, computer_choice)
  prompt("You chose #{choice}; Computer chose: #{computer_choice}")
end

def play_again?(message)
  answer = nil

  loop do
    messages(message)
    answer = gets.chomp.downcase
    break if ['y', 'yes', 'q', 'quit'].include?(answer)
    messages('invalid_input')
    line_break
  end

  answer == 'q' || answer == 'quit'
end

def keep_score(score, winner)
  if winner == "player"
    score[:player] += 1
  elsif winner == "computer"
    score[:computer] += 1
  else
    score
  end
end

def display_current_score(score)
  prompt("The score is: Player - #{score[:player]} : " \
  "Computer - #{score[:computer]}")
  line_break
end

def grand_winner?(score)
  score[:player] == 5 || score[:computer] == 5
end

def declare_grand_winner(score)
  if score[:player] == 5
    messages('player_grand_winner')
  elsif score[:computer] == 5
    messages('computer_grand_winner')
  else
    messages('quit_early')
  end

  line_break
end

def break_condition(score)
  score[:player] < 5 && score[:computer] < 5
end

clear
display_welcome_message
loop do
  score = { player: 0, computer: 0 }
  until grand_winner?(score)
    choice = user_choice
    computer_choice = VALID_CHOICES.values.sample
    winner = round_winner(choice, computer_choice)
    clear
    display_choices(choice, computer_choice)
    display_result(winner)
    keep_score(score, winner)
    display_current_score(score)
    if break_condition(score)
      break if play_again?('continue?')
      clear
    end
  end

  declare_grand_winner(score)
  break if play_again?('play_again?')
  clear
end

clear
messages('exit_message')
