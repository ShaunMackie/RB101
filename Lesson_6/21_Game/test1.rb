require 'pry'

SUITS = %w(H D S C).freeze
VALUES = %w(2 3 4 5 6 7 8 9 10 J Q K A).freeze

def prompt(msg)
  puts "=> #{msg}"
end

def initialize_deck
  SUITS.product(VALUES).shuffle
end

def total(cards)
  values = cards.map { |card| card[1] }
  sum = 0
  sum += sum_of_cards(values)
  correct_for_aces(values, sum)
end

def correct_for_aces(values, sum)
  values.select { |value| value == 'A' }.count.times do
    sum -= 10 if sum > 21
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
  elsif value.to_i.zero?
    10
  else
    value.to_i
  end
end

def busted?(cards)
  total(cards) > 21
end

# :tie, :dealer, :player, :dealer_busted, :player_busted
def detect_result(dealer_cards, player_cards)
  player_total = total(player_cards)
  dealer_total = total(dealer_cards)

  return :player_busted if player_total > 21
  return :dealer_busted if dealer_total > 21
  return :player if dealer_total < player_total
  return :dealer if dealer_total > player_total
  :tie
end

def display_result(dealer_cards, player_cards)
  result = detect_result(dealer_cards, player_cards)

  case result
  when :player_busted
    prompt 'You busted! Dealer wins!'
  when :dealer_busted
    prompt 'Dealer busted! You win!'
  when :player
    prompt 'You win!'
  when :dealer
    prompt 'Dealer wins!'
  when :tie
    prompt "It's a tie!"
  end
end

def play_again?
  puts '-------------'
  prompt 'Do you want to play again? (y or n)'
  answer = gets.chomp
  answer.downcase.start_with?('y')
end

def hit_or_stay
  player_turn = nil
  loop do
    prompt 'Would you like to (h)it or (s)tay?'
    player_turn = gets.chomp.downcase
    break if %w(h s).include?(player_turn)
    prompt "Sorry, must enter 'h' or 's'."
  end

  player_turn
end

def player_hit(player_turn, player_cards, deck)
  if player_turn == 'h'
    player_cards << deck.pop
    prompt 'You chose to hit!'
    prompt "Your cards are now: #{player_cards}"
    prompt "Your total is now: #{total(player_cards)}"
  end
  player_cards
end

def compare_cards(dealer_cards, player_cards)
  puts '=============='
  prompt "Dealer has #{dealer_cards}, for a total of: #{total(dealer_cards)}"
  prompt "Player has #{player_cards}, for a total of: #{total(player_cards)}"
  puts '=============='
end

def initial_deal(player_cards, dealer_cards, deck)
  2.times do
    player_cards << deck.pop
    dealer_cards << deck.pop
  end
end

loop do
  prompt 'Welcome to Twenty-One!'

  # initialize vars
  deck = initialize_deck
  player_cards = []
  dealer_cards = []

  # initial deal
  initial_deal(player_cards, dealer_cards, deck)

  prompt "Dealer has #{dealer_cards[0]} and ?"
  prompt "You have: #{player_cards[0]} and #{player_cards[1]}, for a total of #{total(player_cards)}."

  # player turn
  loop do
    player_turn = hit_or_stay
    player_hit(player_turn, player_cards, deck)
    break if player_turn == 's' || busted?(player_cards)
  end

  if busted?(player_cards)
    display_result(dealer_cards, player_cards)
    play_again? ? next : break
  else
    prompt "You stayed at #{total(player_cards)}"
  end

  # dealer turn
  prompt 'Dealer turn...'

  loop do
    break if total(dealer_cards) >= 17

    prompt 'Dealer hits!'
    dealer_cards << deck.pop
    prompt "Dealer's cards are now: #{dealer_cards}"
  end

  if busted?(dealer_cards)
    prompt "Dealer total is now: #{total(dealer_cards)}"
    display_result(dealer_cards, player_cards)
    play_again? ? next : break
  else
    prompt "Dealer stays at #{total(dealer_cards)}"
  end

  # both player and dealer stays - compare cards!
  compare_cards(dealer_cards, player_cards)

  display_result(dealer_cards, player_cards)

  break unless play_again?
end

prompt 'Thank you for playing Twenty-One! Good bye!'
