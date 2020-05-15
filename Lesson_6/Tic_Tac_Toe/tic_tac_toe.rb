require 'yaml'
require 'pry'

WHO_GOES_FIRST = 'Choose'.freeze

MESSAGES = YAML.load_file('tic_tac_toe.yaml')

WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                [[2, 5, 8], [1, 4, 7], [3, 6, 9]] +
                [[1, 5, 9], [3, 5, 7]]

INITIAL_MARKER = ' '.freeze
PLAYER_MARKER = 'X'.freeze
COMPUTER_MARKER = 'O'.freeze

def prompt(msg)
  puts "=> #{msg}"
end

def messages(message)
  prompt(MESSAGES[message])
end

def line_break
  puts "\n"
end

def clear
  system('clear') || system('cls')
end

def choose_first_player
  messages('go_first?')
  loop do
    answer = gets.chomp.downcase
    return 'Player' if answer == 'p'
    return 'Computer' if answer == 'c'
    messages('invalid_go_first')
    break if answer == 'p' || answer == 'c'
  end
end

def default_first_player
  if WHO_GOES_FIRST == 'Choose'
    choose_first_player
  elsif WHO_GOES_FIRST == 'Player'
    'Player'
  else
    'Computer'
  end
end

def alternate_player(current_player)
  if current_player == 'Player'
    'Computer'
  else
    'Player'
  end
end

def place_piece!(board, current_player)
  if current_player == 'Player'
    player_places_piece!(board)
  else
    computer_places_piece!(board)
  end
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def display_board(brd)
  clear
  puts "You're an #{PLAYER_MARKER}. Computer is #{COMPUTER_MARKER}."
  puts ''
  puts '     |     |'
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts '     |     |'
  puts '-----+-----+-----'
  puts '     |     |'
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts '     |     |'
  puts '-----+-----+-----'
  puts '     |     |'
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts '     |     |'
  puts ''
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def joinor(arr, delimiter = ', ', word = 'or')
  case arr.size
  when 0 then ''
  when 1 then arr.first
  when 2 then arr.join(" #{word} ")
  else
    arr[-1] = "#{word} #{arr.last}"
    arr.join(delimiter)
  end
end

def player_places_piece!(brd)
  square = ''
  loop do
    prompt "Choose a position to place a piece: #{joinor(empty_squares(brd))}"
    square = gets.chomp
    break if empty_squares(brd).include?(square.to_i) && square.length == 1
    messages 'invalid_choice'
  end
  square = square.to_i
  brd[square] = PLAYER_MARKER
end

def computer_tactics(brd, marker)
  square = nil
  WINNING_LINES.each do |line|
    square = find_at_risk_square(line, brd, marker)
    break if square
  end
  square
end

def computer_places_piece!(brd)
  square = computer_tactics(brd, COMPUTER_MARKER)
  square = computer_tactics(brd, PLAYER_MARKER) unless square

  unless square
    if brd[5] == ' '
      brd[5] = COMPUTER_MARKER
    else
      square = empty_squares(brd).sample
    end
  end
  brd[square] = COMPUTER_MARKER
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd)
  detect_winner(brd)
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    return 'Player' if brd.values_at(*line).count(PLAYER_MARKER) == 3
    return 'Computer' if brd.values_at(*line).count(COMPUTER_MARKER) == 3
  end
  nil
end

def keep_score(score, winner)
  if winner == 'Player'
    score[:player] += 1
  elsif winner == 'Computer'
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
    clear
    messages('quit_early')
    line_break
  end
end

def play_again?(message)
  answer = nil
  loop do
    messages(message)
    answer = gets.chomp.downcase
    break if %w(y yes n no).include?(answer)
    messages('invalid_input')
    line_break
  end
  answer == 'n' || answer == 'no'
end

def find_at_risk_square(line, board, marker)
  return nil unless at_risk_square?(line, board, marker)

  board.select { |k, v| line.include?(k) && v == INITIAL_MARKER }.keys.first
end

def at_risk_square?(line, board, marker)
  board.values_at(*line).count(marker) == 2
end

def display_results(board)
  if someone_won?(board)
    prompt "#{detect_winner(board)} won!"
  else
    messages('tie')
  end
  line_break
end

clear
messages('welcome')
messages('rules')
line_break
loop do
  score = { player: 0, computer: 0 }
  loop do
    board = initialize_board
    current_player = default_first_player
    loop do
      display_board(board)
      place_piece!(board, current_player)
      current_player = alternate_player(current_player)
      break if someone_won?(board) || board_full?(board)
    end

    display_board(board)
    display_results(board)
    keep_score(score, detect_winner(board))
    display_current_score(score)
    break if grand_winner?(score)
    break if play_again?('continue?')
    clear
  end

  declare_grand_winner(score)
  break if play_again?('another_round?')
  clear
end

clear
messages('exit_message')
