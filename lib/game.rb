WIN_CONDITION = [[1, 2, 3], [1, 5, 9], [1, 4, 7], [3, 6, 9], [7, 8, 9], [4, 5, 6], [2, 5, 8], [3, 5, 7]].freeze

## Class for the game Tic-tac-toe
class NewGame
  def initialize
    @total_inputs = {
      'Cross' => [],
      'Nought' => []
    }
    @original_board = "1 |2 |3 \n--|--|--\n4 |5 |6 \n--|--|--\n7 |8 |9\n"
    @new_board = ''
    @selected_blocks = []
  end

  # Control the player-visible level of the game
  def gameplay
    puts @original_board

    until win? || draw?
      @total_inputs.each_key do |key|
        prompt_input(key)
        puts @new_board
        if win?
          win_message(key)
          break
        elsif draw?
          draw_message
          break
        end
      end
    end
  end

  def prompt_input(player, input = 0)
    until input.between?(1, 9)
      puts "\n#{player}'s turn:\n\nChoose a numbered block between 1 and 9!"
      input = gets.chomp.to_i
      if @selected_blocks.include?(input)
        puts "\nThis block is occupied! Pick another!"
        redo
      end
    end
    input_storage(player, input)
    game_board(player, input)
  end

  def game_board(player, input)
    if player == 'Cross'
      @original_board.gsub!(input.to_s, 'X')
    else
      @original_board.gsub!(input.to_s, 'O')
    end
    @new_board = @original_board.gsub(/\d/, ' ')
  end

  # Stores all players' inputs
  def input_storage(player, input)
    @total_inputs[player].push(input)
    @selected_blocks.push(input)
  end

  def draw?
    @selected_blocks.sort.eql?([1, 2, 3, 4, 5, 6, 7, 8, 9])
  end

  def win?
    @total_inputs.any? do |_key, value|
      WIN_CONDITION.any? do |item|
        item.all? do |i|
          value.include?(i)
        end
      end
    end
  end

  private

  def draw_message # Doesn't need to test
    puts "\nIt's a draw!"
  end

  def win_message(player) # Doesn't need to test
    puts "\nTic-tac-toe! Three-in-a-row!\n\n#{player} wins!"
  end
end

def play_again?
  play_again = $stdin.gets.chomp.downcase
  if play_again.include?('y')
    true
  elsif play_again.include?('n')
    false
  else
    puts "\nPlease enter 'y' or 'n'."
    play_again?
  end
end

## Game loop
# loop do
#   game = NewGame.new
#   game.gameplay
#   puts "\nWould you like to play again? (y/n)"
#   play_again? ? redo : break
# end
