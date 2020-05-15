require 'yaml'
MESSAGES = YAML.load_file('loan_calc_messages.yml')

loan = ''.to_i
apr = ''
loan_dur = ''

def prompt(message)
  Kernel.puts("=> #{message}")
end

def monthly_rate(rate)
  rate / 12 / 100
end

def monthly_loan_dur(years)
  years * 12
end

def monthly_payment(loan, monthly_rate, monthly_loan_dur)
  loan * (monthly_rate / (1 - (1 + monthly_rate)**(-monthly_loan_dur)))
end

def valid_number?(num)
  num.to_i() != 0 && num.to_i() > 0
end

def integer?(input)
  input.to_i().to_s() == input
end

def new_calculation?(answer)
  answer.downcase() == 'y' || answer.downcase() == 'yes'
end

def exit_program?(answer)
  answer.downcase() == 'n' || answer.downcase() == 'no'
end

def clear
  system('clear') || system('cls')
end

def retreive_loan_amount
  loop do
    prompt(MESSAGES['loan_amount'])
    loan = Kernel.gets().chomp().to_i
    if valid_number?(loan)
      return loan
    else
      prompt(MESSAGES['invalid_loan_amount'])
    end
  end
end

def retrieve_apr_amount
  loop do
    prompt(MESSAGES['apr'])
    apr = Kernel.gets().chomp().to_f
    if valid_number?(apr)
      return apr
    else
      prompt(MESSAGES['invalid_apr'])
    end
  end
end

def retrieve_loan_duration
  loop do
    prompt(MESSAGES['loan_duration'])
    loan_dur = Kernel.gets().chomp()
    if valid_number?(loan_dur) && integer?(loan_dur)
      return loan_dur.to_i
    else
      prompt(MESSAGES['invalid_loan_duration'])
    end
  end
end

def exit_answer
  loop do
    prompt(MESSAGES['another_calc'])
    answer = Kernel.gets().chomp()
    if exit_program?(answer) || new_calculation?(answer)
      return answer
    else
      puts "Invalid answer."
    end
  end
end

prompt(MESSAGES['welcome'])

loop do
  loan = loan_amount
  apr = apr_amount
  loan_dur = loan_duration

  payment = monthly_payment(loan, monthly_rate(apr), monthly_loan_dur(loan_dur))
  prompt format("Your monthly payment is $%0.2f", payment)

  answer = exit_answer
  break if exit_program?(answer)
  clear
  prompt(MESSAGES['welcome'])
end

prompt(MESSAGES['exit_message'])
