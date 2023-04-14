WIN_CONDITION = [[1, 2, 3], [1, 5, 9], [1, 4, 7], [3, 6, 9], [7, 8, 9], [4, 5, 6], [2, 5, 8], [3, 5, 7]].freeze

## Class for the game Tic-tac-toe
class NewGame
  def initialize(players)
    @total_inputs = {
      players[0] => [],
      players[1] => []
    }
    @original_board = "1 |2 |3 \n--|--|--\n4 |5 |6 \n--|--|--\n7 |8 |9\n"
    @new_board = ''
    @selected_blocks = []
  end

  # Control the player-visible level of the game
  def gameplay
    puts @original_board
    loop do
      @total_inputs.each_key do |player|
        input = (player == 'Cross' ? minimax(@total_inputs, @selected_blocks, true)[1] : 0)
        prompt_input(player, input)
        puts @new_board
        
        return game_end_message(@total_inputs, @selected_blocks) if game_end?(@total_inputs, @selected_blocks)
      end
    end
  end

  def prompt_input(player, input = 0)
    puts "\n#{player}'s turn:\n"
    until input.between?(1, 9)
      puts "\nChoose a numbered block between 1 and 9!"
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

  def draw?(board_state)
    board_state.sort.eql?([1, 2, 3, 4, 5, 6, 7, 8, 9])
  end

  def win?(player_state, player)
    WIN_CONDITION.any? do |item|
      item.all? do |i|
        player_state[player].include?(i)
      end
    end
  end

  def game_end?(player_state, board_state)
    win?(player_state, 'Cross') || win?(player_state, 'Nought') || draw?(board_state)
  end

  def evaluate_score(player_state, board_state)
    if win?(player_state, 'Cross')
      1
    elsif win?(player_state, 'Nought')
      -1
    elsif draw?(board_state)
      0
    end
  end

  def deep_dup(obj)
    Marshal.load(Marshal.dump(obj))
  end

  def available_moves(board_state)
    [1, 2, 3, 4, 5, 6, 7, 8, 9] - board_state
  end

  def minimax(player_state, board_state, is_maximizing, alpha = -2, beta = 2)
    if game_end?(player_state, board_state)
      return [evaluate_score(player_state, board_state)]
    else
      scores = is_maximizing ? -2 : 2
      next_move = 0
      available_moves(board_state).each do |i|
        simulate_inputs = deep_dup(player_state)
        simulate_selected = deep_dup(board_state)
        simulate_selected << i
        player = is_maximizing ? 'Cross' : 'Nought'
        simulate_inputs[player] << i

        new_score = minimax(simulate_inputs, simulate_selected, !is_maximizing, alpha, beta)[0]

        if is_maximizing
          if scores < new_score
            scores = new_score
            next_move = i
          end
        else
          if scores > new_score
            scores = new_score
            next_move = i
          end
        end

        # Alpha-beta pruning
        if is_maximizing
          if alpha < new_score
            alpha = new_score
          end
        else
          if beta > new_score
            beta = new_score
          end
        end

        if alpha >= beta
          break
        end
      end
      [scores, next_move]
    end
  end

  private

  def game_end_message(player_state, board_state)
    if win?(player_state, 'Cross')
      win_message('Cross')
    elsif win?(player_state, 'Nought')
      win_message('Nought')
    elsif draw?(board_state)
      draw_message
    end
  end

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
loop do
  game = NewGame.new(['Cross', 'Nought'].shuffle)
  game.gameplay
  puts "\nWould you like to play again? (y/n)"
  play_again? ? redo : break
end
