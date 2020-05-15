# last thing we were working on was deal_cards def. It works except danger over dealing
# same card twice so need to remove a card from the deck, once that card has been dealt
# also that method could quickly start doing too many things, might need to break it up

SUITS = %w( H D S C)

RANKS = %w(2 3 4 5 6 7 8 9 T J Q K A)

def deck
  SUITS.product(RANKS)
end

def deal_cards(deck)
  2.times do
  card = deck.sample.join.reverse
  puts card[0]+card[1].downcase
  end
end

def display_cards(deck)
  card = deck[1] + deck[0].downcase
  p card
end

def total(cards)
  # cards = [['H', '3'], ['S', 'Q'], ... ]
  values = cards.map { |card| card[1] }

  sum = 0
  values.each do |value|
    if value == "A"
      sum += 11
    elsif value.to_i == 0 # J, Q, K
      sum += 10
    else
      sum += value.to_i
    end
  end

  values.select { |value| value == "A" }.count.times do
    sum -= 10 if sum > 21
  end

  sum
end

deal_cards(deck)




  


