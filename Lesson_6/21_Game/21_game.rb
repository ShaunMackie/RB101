require 'yaml'
MESSAGES = YAML.load_file('21_Game.yml')

SUITS = %w(h d s c).freeze
VALUES = %w(2 3 4 5 6 7 8 9 10 J Q K A).freeze

DEALER_TARGET = 17
GAME_LIMIT = 21

def prompt(msg)
  puts "=> #{msg}"
end

def messages(message)
  prompt(MESSAGES[message])
end

def clear
  system('clear')
end

def line_break
  puts "\n"
end

def initialize_deck
  SUITS.product(VALUES).shuffle.map { |arr| arr.reverse.join }
end

def total(cards)
  values = cards.map { |card| card[0] }
  sum = 0
  sum += sum_of_cards(values)
  correct_for_aces(values, sum)
end

def correct_for_aces(values, sum)
  values.select { |value| value == 'A' }.count.times do
    sum -= 10 if sum > GAME_LIMIT
  end
  sum
end

def sum_of_cards(values)
  sum = 0
  values.each do |value|
    sum += determine_value(value)
  end
  sum
end

def determine_value(value)
  if value == 'A'
    11
  elsif value.to_i.zero? || value.to_i == 1
    10
  else
    value.to_i
  end
end

def busted?(cards)
  total(cards) > GAME_LIMIT
end

def detect_result(dealer_cards, player_cards)
  player_total = total(player_cards)
  dealer_total = total(dealer_cards)

  return :player_busted if player_total > GAME_LIMIT
  return :dealer_busted if dealer_total > GAME_LIMIT
  return :player if dealer_total < player_total
  return :dealer if dealer_total > player_total
  :tie
end

def display_result(dealer_cards, player_cards)
  result = detect_result(dealer_cards, player_cards)

  case result
  when :player_busted
    messages('player_busted')
  when :dealer_busted
    messages('dealer_busted')
  when :player
    messages('player_win')
  when :dealer
    messages('dealer_wins')
  when :tie
    messages('tie')
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

  answer == 'y' || answer == 'yes'
end

def hit_or_stay
  player_turn = nil
  loop do
    messages('hit_or_stay')
    player_turn = gets.chomp.downcase
    break if %w(h hit s stay).include?(player_turn)
    messages('action_error_msg')
  end

  player_turn
end

def player_hit(player_turn, player_cards, deck)
  if player_turn == 'h' || player_turn == 'hit'
    player_cards << deck.pop
    messages('player_hits')
    prompt "Your cards are now: #{player_cards}"
    prompt "Your total is now: #{total(player_cards)}"
  end
  player_cards
end

def compare_cards(dealer_cards, player_cards)
  messages('lines')
  prompt "Dealer has #{dealer_cards}, for a total of: #{total(dealer_cards)}"
  prompt "Player has #{player_cards}, for a total of: #{total(player_cards)}"
  messages('lines')
end

def initial_deal(player_cards, dealer_cards, deck)
  2.times do
    player_cards << deck.pop
    dealer_cards << deck.pop
  end
end

def display_initial_deal(player_cards, dealer_cards)
  prompt "Dealer has #{dealer_cards[0]} and ?"
  prompt "You have: #{player_cards[0]} and #{player_cards[1]}, for a total of #{total(player_cards)}."
end

def dealer_hits(dealer_cards, deck)
  loop do
    break if total(dealer_cards) >= DEALER_TARGET
    messages('dealer_hits')
    dealer_cards << deck.pop
    prompt "Dealer's cards are now: #{dealer_cards}"
  end
end

def keep_score(score, detect_result)
  if detect_result == :player_busted || detect_result == :dealer
    score[:Player] += 1
  elsif detect_result == :dealer_busted || detect_result == :player
    score[:Dealer] += 1
  else
    score
  end
end

def display_current_score(score)
  messages('lines')
  prompt("The score is: Player - #{score[:Player]} : " \
  "Dealer - #{score[:Dealer]}")
  messages('lines')
end

def grand_winner?(score)
  score[:Player] == 5 || score[:Dealer] == 5
end

def declare_grand_winner(score)
  line_break
  if score[:Player] == 5
    messages('player_grand_winner')
  elsif score[:Dealer] == 5
    messages('computer_grand_winner')
  end

  line_break
end

def players_turn(player_cards, deck)
  loop do
    player_turn = hit_or_stay
    player_hit(player_turn, player_cards, deck)
    break if %w(s stay).include?(player_turn) || busted?(player_cards)
  end
end

def display_game_results(player_cards, dealer_cards, score)
  compare_cards(dealer_cards, player_cards)
  display_result(dealer_cards, player_cards)
  keep_score(score, detect_result(player_cards, dealer_cards))
  display_current_score(score)
end

def intro_msgs
  clear
  messages('welcome')
  messages('rules')
  line_break
end

loop do
  score = { Player: 0, Dealer: 0 }
  intro_msgs
  loop do
    clear
    deck = initialize_deck
    player_cards = []
    dealer_cards = []

    initial_deal(player_cards, dealer_cards, deck)
    display_initial_deal(player_cards, dealer_cards)

    players_turn(player_cards, deck)

    if busted?(player_cards)
      display_game_results(player_cards, dealer_cards, score)
      break if grand_winner?(score)
      play_again?('continue?') ? next : break
    else
      prompt "You stayed at #{total(player_cards)}"
    end

    messages('dealers_turn')
    dealer_hits(dealer_cards, deck)
    if busted?(dealer_cards)
      prompt "Dealer total is now: #{total(dealer_cards)}"
      display_game_results(player_cards, dealer_cards, score)
      break if grand_winner?(score)
      play_again?('continue?') ? next : break
    else
      prompt "Dealer stays at #{total(dealer_cards)}"
    end

    display_game_results(player_cards, dealer_cards, score)
    break if grand_winner?(score)
    break unless play_again?('continue?')
  end
  declare_grand_winner(score) if grand_winner?(score)
  break unless play_again?('new_match?')
end
clear
messages('exit_message')
