LOAD CSV WITH HEADERS FROM "file:/chessData_games.csv" AS line_game
CREATE (n:Game {date: line_game.date, halfmoves: toInt(line_game.halfmoves), moves: toInt(line_game.moves), result: line_game.result, gamenumber: toInt(line_game.gamenumber) , event: line_game.event, site: line_game.site, eventdate: line_game.eventdate, round: line_game.round, eco: line_game.eco, opening: line_game.opening})
MERGE (p1:Player {name: line_game.white})
MERGE (p2:Player {name: line_game.black})
CREATE (p1)-[w:Plays {side: 'white', elo: line_game.whiteelo}]->(n)
CREATE (p2)-[b:Plays {side: 'black', elo: line_game.blackelo}]->(n)

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/chessData_moves.csv" as line_moves
CREATE (p:Position {positionnumber: toInt(line_moves.movenumber), fen: line_moves.fen, gamenumber: toInt(line_moves.gamenumber)})
WITH COLLECT(DISTINCT p.gamenumber) AS pp
FOREACH (gamenu in pp |
	CREATE (p:Position {positionnumber: 0, fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR', gamenumber: gamenu}))

CREATE INDEX ON :Game(gamenumber);
CREATE INDEX ON :Position(gamenumber);
CREATE INDEX ON :Position(positionnumber);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/chessData_moves.csv" AS line_moves
MATCH (pos:Position {gamenumber: toInt(line_moves.gamenumber)})
MATCH (g:Game {gamenumber: toInt(line_moves.gamenumber)})
MERGE (g)-[:CONTAINS]->(pos);

LOAD CSV WITH HEADERS FROM "file:/chessData_moves.csv" AS line_move
MATCH (pos1:Position {gamenumber: toInt(line_move.gamenumber), positionnumber: toInt(line_move.movenumber)-1})
MATCH (pos2:Position {gamenumber: toInt(line_move.gamenumber), positionnumber: toInt(line_move.movenumber)})
MERGE (pos1)-[:Move {side: line_move.side, move: line_move.move}]->(pos2)

MATCH (g1:Game)-[:CONTAINS]->(pos:Position {fen: 'r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R'})
WITH COUNT(g1) AS c
MATCH (g2:Game {result: 'White'})-[:CONTAINS]->(pos:Position {fen: 'r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R'})
RETURN c, (count(g2)/1.0)/(c/1.0)

MATCH (g1:Game)-[:CONTAINS]->(pos:Position {fen: 'r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R'})
WITH COUNT(g1) AS c
MATCH (g2:Game {result: 'White'})-[:CONTAINS]->(pos:Position {fen: 'r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R'})
WITH COUNT(g2) AS ww, c
MATCH (g3:Game {result: 'Black'})-[:CONTAINS]->(pos:Position {fen: 'r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R'})
WITH COUNT(g3) AS bw, ww, c
MATCH (g4:Game {result: 'Draw'})-[:CONTAINS]->(pos:Position {fen: 'r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R'})
WITH COUNT(g4) AS dr, bw, ww, c
RETURN ww*1.0/c AS White_Wins, bw*1.0/c AS Black_Wins, dr*1.0/c AS Draw

MATCH (g:Game)
WITH DISTINCT g.event AS events, COUNT(g) as game_no
ORDER BY game_no DESC
WITH MAX(game_no) as max_game_no
MATCH (g:Game)
WITH DISTINCT g.event AS events, COUNT(g) as game_no, max_game_no
WITH FILTER (event in events WHERE game_no=max_game_no) as events
MATCH (pl:Player {name: 'Karpov  Anatoly'})-->(g:Game)
WHERE g.event in events
RETURN COUNT(pl), g.event

MATCH (pl:Player)-[:Plays]->(g:Game {opening: 'Ruy Lopez'})
RETURN DISTINCT pl as pl_name, COUNT(g) as games
ORDER BY games DESC
LIMIT 1

MATCH (pl:Player)-->(g:Game)-->(:Position)-[:Move {move: 'Nc6'}]->(:Position)-[:Move {move: 'Bb5'}]->(:Position)-[:Move {move: 'a6'}]->(:Position)
WITH COUNT(g) AS games_no
MATCH (pl:Player)-->(g:Game)-->(:Position)-[:Move {move: 'Nc6'}]->(:Position)-[:Move {move: 'Bb5'}]->(:Position)-[:Move {move: 'a6'}]->(:Position)
RETURN DISTINCT pl.name, games_no

MATCH (pl:Player)-->(:Game {gamenumber: 636})
RETURN pl.name

MATCH (g:Game {gamenumber: 636})
RETURN g

MATCH p = (g:Game {gamenumber: 636})-->(pos:Position {positionnumber: 0})-[m:Move*]->(pos2:Position)
WITH COLLECT(p) as p, MAX(length(p)) AS maxLength
WITH FILTER(path IN p
	WHERE length(path)= maxLength) AS longestPath, p
Return extract(x IN relationships(longestPath[0]) | x.move)