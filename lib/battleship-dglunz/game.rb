class Game
  attr_reader :round,
              :board,
              :display,
              :coordinates,
              :check,
              :player_1,
              :player_2,
              :result

  def initialize(display, player_1, player_2, check, stdin)
    @player_1    = player_1
    @player_2    = player_2
    @check       = check
    @round       = 0
    @display     = display
    @board       = Board.new
    @coordinates = ''
    @stdin       = stdin
  end

  def start
    board.show_ocean
    ocean_setup
    target_setup
    game_loop
  end

  def game_loop
    until finished?
      get_input
      valid_attack_input? ? play_round : invalid_input
    end
    game_over
  end

  def play_round
    @round += 1
    check_fired_shots
    update_board
    show_round_result
  end

  def ocean_setup
    player_1.fleet.ships.each do |ship|
      update_ship_location(ship)
      display.battleship_logo
      board.show_ocean
    end
  end

  def target_setup
    display.battleship_logo
    display.target_setup
    board.show_both
  end

  def check_fired_shots
    @result = check.attack(player_2, coordinates)
    hit? ? board.target_hit(coordinates) : board.target_miss(coordinates)
  end

  def update_board
    display.battleship_logo
    # @finished ? finish_board
    board.show_both
  end

  def update_ship_location(ship)
    display.add_ship(ship)
    @coordinates = @stdin.gets.chomp.upcase
    valid_ship_placement?(ship) ? (ship.location = coordinates) : update_ship_location(ship)
    board.add_ship(ship)
  end

  def hit?
    result.length == 1
  end

  def win?

  end

  def quit?
    coordinates == 'Q' || coordinates == 'QUIT'
  end

  def finished?
    # round_limit = 10
    # round >= round_limit ||
     quit? || win?
  end

  def show_round_result
    @result.length == 1 ? display.hit(@result.first) : display.miss
  end

  def get_input
    display.enter_guess
    @coordinates = @stdin.gets.chomp.upcase
  end

  def finish_board
    board.finished(round, history)
  end

  def valid_attack_input?
    expected_length?(2) && within_bounds?
  end

  def expected_length?(expected)
    coordinates.length == expected
  end

  def within_bounds?
    within_column_range? && within_row_range?
  end

  def within_row_range?
    coordinates[1].to_i.between?(1,4)
  end

  def within_column_range?
    coordinates[0].scan(/[^ABCD]/).length == 0
  end

  def valid_ship_placement?(ship)
    #withinbounds only compares the first coordinate
    valid_ship_size?(ship) && within_bounds? && !diagonal? && !overlapping?
  end

  def overlapping?
    if player_1.fleet.ships[0].location.nil? == false
      coordinates.split(" ").select do |coordinate|
        player_1.fleet.ships[0].location.include?(coordinate)
      end.count > 0
    end
  end

  def valid_ship_size?(ship)
    coordinates.split(" ").count == ship.size
  end

  def invalid_input
    quit? ? return : display.invalid_input(coordinates)
  end

  def game_over
    update_board
    win? ? display.winner : display.loser
  end

  def diagonal?
    vertical = %w(A B C D)
    horizontal = %w(1 2 3 4)
    coordinates_a = coordinates.split(" ")
    h = horizontal.index(coordinates_a[0][1]) - horizontal.index(coordinates_a[1][1])
    v = vertical.index(coordinates_a[0][0]) - vertical.index(coordinates_a[1][0])
    t = h.abs + v.abs
    t > 1
  end
end
