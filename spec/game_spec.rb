require_relative '../lib/game'

describe NewGame do

  subject(:game) { described_class.new }
  let(:player_state) { game.instance_variable_get(:@total_inputs) }

  describe '#win?' do

    context 'when blocks occupied by a symbol include three blocks in a row' do
      it 'returns true' do
        game.instance_variable_set(:@total_inputs, {'Cross' => [4, 2, 6, 5]})
        expect(game.win?(player_state, 'Cross')).to be true
      end
    end

    context 'when blocks occupied by a symbol include three blocks in a column' do
      it 'returns true' do
        game.instance_variable_set(:@total_inputs, {'Cross' => [4, 1, 6, 2, 7]})
        expect(game.win?(player_state, 'Cross')).to be true
      end
    end

    context 'when blocks occupied by a symbol include three blocks in a diagonal' do
      it 'returns true' do
        game.instance_variable_set(:@total_inputs, {'Nought' => [1, 5, 3, 7]})
        expect(game.win?(player_state, 'Nought')).to be true
      end
    end

    context 'when blocks occupied by a symbol do not form a line of three blocks' do
      it 'returns false' do
        game.instance_variable_set(:@total_inputs, {'Nought' => [1, 5, 3, 8]})
        expect(game.win?(player_state, 'Nought')).to be false
      end
    end
  end

  describe '#gameplay' do

    context 'when #win?' do

      before do
        allow(game).to receive(:puts)
        allow(game).to receive(:prompt_input)
        allow(game).to receive(:win?).and_return(true)
      end

      it 'returns #game_end_message' do
        expect(game).to receive(:game_end_message)

        game.gameplay
      end
    end

    context 'when #draw?' do

      before do
        allow(game).to receive(:puts)
        allow(game).to receive(:prompt_input)
        allow(game).to receive(:draw?).and_return(true)
      end

      it 'returns #game_end_message' do
        allow(game).to receive(:game_end_message)

        game.gameplay
      end
    end

    context 'when not #win? or #draw?, then #draw?' do

      before do
        allow(game).to receive(:puts)
        allow(game).to receive(:prompt_input)
        allow(game).to receive(:win?).and_return(false)
        allow(game).to receive(:draw?).and_return(false, true)
      end

      it 'returns #game_end_message' do
        allow(game).to receive(:game_end_message)

        game.gameplay
      end
    end
  end

  describe '#prompt_input' do

    before do
      allow(game).to receive(:puts)
      allow(game).to receive(:input_storage)
      allow(game).to receive(:game_board)
    end

    context 'when input is not between 1 and 9, then is between 1 and 9' do

      before { allow(game).to receive(:gets).and_return('r', '5') }

      it 'receives #gets twice' do
        expect(game).to receive(:gets).twice

        game.prompt_input('Cross')
      end
    end

    context 'when input is between 1 and 9' do

      context 'when input points to an occupied block, then does not' do

        before do
          allow(game).to receive(:gets).and_return('3', '2')
          game.instance_variable_set(:@selected_blocks, [1, 3, 4])
        end

        it 'puts error message' do
          error_message = "\nThis block is occupied! Pick another!"
          expect(game).to receive(:puts).with(error_message)

          game.prompt_input('Nought')
        end
      end
    end
  end

  describe '#game_board' do

    let(:original_board) { game.instance_variable_get(:@original_board) }

    context 'when player is Cross and inputs at block 5' do

      before { game.game_board('Cross', 5) }

      it 'replaces the input number with X on the board' do
        expect(original_board).to eql("1 |2 |3 \n--|--|--\n4 |X |6 \n--|--|--\n7 |8 |9\n")
      end

      it 'sends updated board to @new_board' do
        new_board = game.instance_variable_get(:@new_board)
        expect(new_board).to eql("  |  |  \n--|--|--\n  |X |  \n--|--|--\n  |  | \n")
      end
    end

    context 'when player is Nought' do
      
      before { game.game_board('Nought', 7) }

      it 'replaces the input number with O on the board' do
        expect(original_board).to eql("1 |2 |3 \n--|--|--\n4 |5 |6 \n--|--|--\nO |8 |9\n")
      end

      it 'sends updated board to @new_board' do
        new_board = game.instance_variable_get(:@new_board)
        expect(new_board).to eql("  |  |  \n--|--|--\n  |  |  \n--|--|--\nO |  | \n")
      end
    end
  end

  describe '#input_storage' do

    let(:total_inputs) { game.instance_variable_get(:@total_inputs) }
    let(:selected_blocks) { game.instance_variable_get(:@selected_blocks) }
    
    context 'when player is Cross' do

      it 'sends input to @total_inputs' do
        expect(total_inputs['Cross']).to receive(:push).with(1)

        game.input_storage('Cross', 1)
      end

      it 'sends input to @selected_blocks' do
        expect(selected_blocks).to receive(:push).with(1)

        game.input_storage('Cross', 1)
      end
    end

    context 'when player is Nought' do

      it 'sends input to @total_inputs' do
        expect(total_inputs['Nought']).to receive(:push).with(7)

        game.input_storage('Nought', 7)
      end

      it 'sends input to @selected_blocks' do
        expect(selected_blocks).to receive(:push).with(7)

        game.input_storage('Nought', 7)
      end
    end
  end

  describe '#draw?' do

    let(:game_state) { game.instance_variable_get(:@selected_blocks) }

    context 'when game is draw (no more moves can be made on board)' do

      it 'returns true' do
        game.instance_variable_set(:@selected_blocks, [2, 3, 6, 4, 9, 7, 8, 1, 5])
        expect(game.draw?(game_state)).to be true
      end
    end

    context 'when game is not draw' do
      
      it 'returns false' do
        game.instance_variable_set(:@selected_blocks, [2, 3, 6, 7, 8, 1, 5])
        expect(game.draw?(game_state)).to be false
      end
    end
  end

  describe '#minimax' do
    
    context 'when Cross is winning' do

      context 'when Cross win by choosing 8 as next move' do

        before do
          new_inputs = {'Cross' => [1, 2, 5], 'Nought' => [3, 4, 9]}
          new_selected = [1, 2, 3, 4, 5, 9]
          game.instance_variable_set(:@total_inputs, new_inputs)
          game.instance_variable_set(:@selected_blocks, new_selected)
        end

        it 'returns array [1, 8]' do
          total_inputs = game.instance_variable_get(:@total_inputs)
          selected_blocks = game.instance_variable_get(:@selected_blocks)
          expect(game.minimax(total_inputs, selected_blocks, true)).to be == [1, 8]
        end
      end

      context 'when Cross will win if 5 is chosen as next move' do

        before do
          new_inputs = {'Cross' => [1, 2], 'Nought' => [3, 4]}
          new_selected = [1, 2, 3, 4]
          game.instance_variable_set(:@total_inputs, new_inputs)
          game.instance_variable_set(:@selected_blocks, new_selected)
        end

        it 'returns array [1, 5]' do
          total_inputs = game.instance_variable_get(:@total_inputs)
          selected_blocks = game.instance_variable_get(:@selected_blocks)
          expect(game.minimax(total_inputs, selected_blocks, true)).to be == [1, 5]
        end
      end
    end

    context 'when Nought is winning' do

      context 'when Nought will win no matter what' do

        before do
          new_inputs = {'Cross' => [7, 8], 'Nought' => [2, 6, 9]}
          new_selected = [2, 6, 7, 8, 9]
          game.instance_variable_set(:@total_inputs, new_inputs)
          game.instance_variable_set(:@selected_blocks, new_selected)
        end

        it 'returns array [-1, 1]' do
          total_inputs = game.instance_variable_get(:@total_inputs)
          selected_blocks = game.instance_variable_get(:@selected_blocks)
          expect(game.minimax(total_inputs, selected_blocks, true)).to be == [-1, 1]
        end
      end
    end

    context 'when the game is going to draw' do

      before do
        new_inputs = {'Cross' => [1, 5, 8], 'Nought' => [2, 6, 7, 9]}
        new_selected = [1, 2, 5, 6, 7, 8, 9]
        game.instance_variable_set(:@total_inputs, new_inputs)
        game.instance_variable_set(:@selected_blocks, new_selected)
      end

      it 'returns array [0, 3]' do
        total_inputs = game.instance_variable_get(:@total_inputs)
        selected_blocks = game.instance_variable_get(:@selected_blocks)
        expect(game.minimax(total_inputs, selected_blocks, true)).to be == [0, 3]
      end
    end
  end
end

describe '#play_again?' do
  
  context "if receives input containing 'y'" do
    
    before { allow($stdin).to receive(:gets).and_return('Yes') }

    it 'returns true' do
      expect(play_again?).to eql true
    end
  end

  context "if receives input containing 'n'" do

    before { allow($stdin).to receive(:gets).and_return('Nooo!') }
    
    it 'returns false' do
      expect(play_again?).to eql false
    end
  end

  context "if receives input containing neither 'y' nor 'n', then receives 'y'" do
    
    before { allow($stdin).to receive(:gets).and_return('blahblah', 'y') }

    it 'receives true' do
      expect($stdout).to receive(:puts).once
      expect(play_again?).to eql true
    end
  end
end
