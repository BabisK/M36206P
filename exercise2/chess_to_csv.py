import csv

def main():
    game = {}
    move = {}
    mode = None
    gamefieldnames = ['white', 'black', 'date', 'halfmoves', 'moves', 'result', 'whiteelo', 'blackelo', 'gamenumber', 'event', 'site', 'eventdate', 'round', 'eco', 'opening']
    movefieldnames = ['movenumber', 'side', 'move', 'fen', 'gamenumber']
    with open('chessData.txt', 'r') as input, open('chessData_games.csv', 'w') as out_games, open('chessData_moves.csv', 'w') as out_moves:
        gamewriter = csv.DictWriter(out_games, fieldnames=gamefieldnames)
        gamewriter.writeheader()

        movewriter = csv.DictWriter(out_moves, fieldnames=movefieldnames)
        movewriter.writeheader()

        for line in input:
            if line == '=========================== Game ======================================================\n':
                mode = 'game'
                game = {}
            elif line == '--------------------------------------------------------- Game Moves ---------------------------------------------------------------------\n':
                gamewriter.writerow(game)
                mode = 'move'
            elif line == '======================================================================================\n':
                pass
            else:
                if mode == 'game':
                    line = line.split(':')
                    game[line[0].strip().lower()] = line[1].strip()
                elif mode == 'move':
                    line = line.split(',')
                    for pair in line:
                        tokens = pair.split(':')
                        move[tokens[0].strip().lower()] = tokens[1].strip()
                    movewriter.writerow(move)


if __name__ == '__main__':
    main()