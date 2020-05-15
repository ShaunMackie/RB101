require 'yaml'
MESSAGES = YAML.load_file('calculator_messages.yml')

def messages(message, lang='en')
  MESSAGES[lang][message]
end

def clear
  system('clear') || system('cls')
end

def prompt(message)
  puts("=> #{message}")
end

def exit_message
  prompt("Thank you for using Calculator! Good bye.")
end

def integer?(input)
  input.to_i.to_s == input
end

def float?(input)
  input.to_f.to_s == input
end

def number?(input)
  integer?(input) || float?(input)
end

def check_zero_division(num1, num2)
  if num2 == 0
    prompt(messages('zero_divison_error'))
  else
    num1 / num2
  end
end

def another_operation?
  answer = nil

  loop do
    prompt(messages('another_operation?'))
    answer = gets.chomp.downcase
    break if ['y', 'yes', 'n', 'no'].include?(answer)
    prompt(messages('exit_error_message'))
  end

  answer == 'y' || answer == 'yes'
end

def operation_to_message(op)
  operation = case op
              when '1'
                "Adding"
              when '2'
                "Subtracting"
              when '3'
                "Multiplying"
              when '4'
                "Dividing"
              end
  operation
end

def request_user_name
  name = nil
  valid_name = nil

  loop do
    name = gets.chomp
    valid_name = name.gsub(/\s+/, "")
    if valid_name.empty?
      prompt(messages('valid_name'))
    else
      prompt("Hi #{name}!")
      break
    end
  end
end

def user_input_number
  number = nil
  loop do
    number = gets.chomp
    if number?(number)
      return number.to_f
    else
      prompt(messages('error_message'))
    end
  end
end

def validate_operator
  loop do
    operator = gets.chomp

    if %w(1 2 3 4).include?(operator)
      return operator
    else
      prompt(messages('valid_choice'))
    end
  end
end

def display_results(result)
  prompt("The result is #{result}.")
end

def strip_trailing_zero(num)
  num.to_s.sub(/\.?0+$/, '')
end

def operator(operator, number1, number2)
  case operator
  when '1'
  when '2'
    number1 - number2
  when '3'
    number1 * number2
  when '4'
    check_zero_division(number1, number2)
  end
end

# program starts here

prompt(messages('welcome', 'es'))

request_user_name

loop do
  prompt(messages('first_number'))
  number1 = user_input_number

  prompt(messages('second_number'))
  number2 = user_input_number

  operator_prompt = <<-MSG
  What operation would you like to perform?
  1) add
  2) subtract
  3) multiply
  4) divide
  MSG

  prompt(operator_prompt)

  operator = valid_operator?

  prompt("#{operation_to_message(operator)} the two numbers...")

  result = operator(operator, number1, number2)

  result = strip_trailing_zero(result)

  display_results(result) unless result == ""

  break unless another_operation?
  clear
end
clear
exit_message
