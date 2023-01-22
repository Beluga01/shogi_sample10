import 'package:flutter/material.dart';
import 'package:flutter_shogi_board/flutter_shogi_board.dart';
import 'package:shogi/shogi.dart';

void main() {
  runApp(
    MaterialApp(
      home: _HomeScreen(),
    ),
  );
}

class _HomeScreen extends StatelessWidget {
  final Map<String, Function(BuildContext)> routes = {
    'Yagura castle building animation': (context) =>
        _showPage(context, _CastleBuildingAnimation()),
    'Tsume (5手詰)': (context) => _showPage(context, _Tsume()),
    'Proverb': (context) => _showPage(context, _Proverb()),
  };

  static void _showPage(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  _HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('flutter_shogi_board'),
      ),
      body: ListView.builder(
        itemCount: routes.length,
        itemBuilder: (_, index) => ListTile(
          title: Text(routes.keys.toList()[index]),
          trailing: Icon(Icons.navigate_next),
          onTap: () => routes.values.toList()[index](context),
        ),
      ),
    );
  }
}

class _CastleBuildingAnimation extends StatefulWidget {
  _CastleBuildingAnimation({Key? key}) : super(key: key);

  @override
  _CastleBuildingAnimationState createState() =>
      _CastleBuildingAnimationState();
}

class _CastleBuildingAnimationState extends State<_CastleBuildingAnimation> {
  late List<Move> moves;
  late GameBoard gameBoard;

  @override
  void initState() {
    super.initState();

   /* final game = '''
1: ☗K59-58
2: ☖K51-52
3: ☗K58-59
4: ☖K52-51
5: ☗K59-58
6: ☖K51-52
7: ☗K58-59
8: ☖K52-51
9: ☗K59-58
10: ☖K51-52
11: ☗K58-59
12: ☖K52-51
13: ☗K59-58
14: ☖K51-52
15: ☗K58-59
16: ☖K52-51
17: ☗K59-58
18: ☖K51-52
19: ☗K58-59
20: ☖K52-51
21: ☗K59-58
22: ☖K51-52
23: ☗K58-59
24: ☖K52-51
25: ☗K59-58
26: ☖K51-52
27: ☗K58-59
28: ☖K52-51
''';*/

     final game = '''
☗P27-26
☖P83-84
☗P26-25
☖P84-85
☗P25-24
☖P85-86
☗P24x23+
☖P86x87+
''';

    //TODO おそらく上の形必須
    //TODO 先手なら☗、後手なら☖が必要、改行も必要、'''で囲む形なにか知らんけど必要
    //TODO 今のとこアプリで使う予定ないけど先手だけを動かすこともできるみたい
    //TODO 成ることができない場所で成るなどの合法手ではない手も指せる

    /*
    TODO --------SFENのmovesをshogiパッケージで動く形に変えるには---------
    ①先手なら☗、後手なら☖をつける

    ②動かす駒に対応するアルファベットを大文字でつける
    歩  P
    香  L
    桂  N
    銀  S
    金  G
    飛  R
    角  B
    玉  K
    と 成香 成桂 成銀 馬 龍など成っている形は+Pなど文字の前に+をつける

    ③横座標は同じなのでそのまま
    縦座標はアルファベット(SFEN)から数字(shogiパッケージ)にする

    ④動かす駒の元の場所、動かす先の場所の順に座標を書く
    shogiパッケージは相手の駒をとらない場合は-、とる場合はxをつける
    2g2f   27-26
    2d2c   24x23

    ⑤成る場合と成駒を動かす場合はどちらも最後に+をつける


 //TODO ※わからないこと: 持ち駒が使えない
    //https://pub.dev/documentation/shogi/latest/
    //Drop: Sente's drops a silver from in hand onto 34.がそれに当たるはずだけど、
    //Null check operator used on a null valueというエラーがでてしまう
    ⑥持ち駒を使う場合
    歩を２五に打つ場合は、SFENはP*2eでできる
    将棋パッケージは☗P*25と書いてあるけどなぜか使えない
    ☗P25
    ☗P-25
    ☗P+25
    ☗P*25
    ☗P25-
    ☗P25+
    ☗P25*
    などなど試したけど使えなさそう・・・わからない

    TODO --------ここまでSFENのmovesをshogiパッケージで動く形に変えるには---------
    */

    // ↓SFEN例
 /*  position sfen lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1 moves 2g2f 3c3d 7g7f 8b4b 3i4h 2b8h+ 7i8h 5a6b 5i6h 6b7b 6h7h 7b8b 9g9f 9c9d 2f2e 4a3b 8h7g 7a7b 6i6h 4b4a 4i3i 3a4b 2e2d 2c2d 2h2d P*2c 2d2c+ 3b2c B*3b 4a3a 3b2c+ R*2g P*2d 3a3c 2c4a 6a5a G*3b 5a4a 3b4a 2g2d+ 4a4b 2d2b 4b5a 3c3b S*4a 3b3a P*2d B*6b G*3b 3a3b 4a3b+ 2b3b R*5b 3b5b 5a5b 6b7a R*2b B*4d 2b2a+ R*2g 2d2c+ P*2h 3i3h 2g2e+ 2c2d 2e2f 2d2e G*2b 2a2b 4d2b 2e2f 2h2i+ R*4b 2b4d G*6b S*3c 4b3b+ 5c5d 6b7b 8b7b N*7e G*6b 5b6b 4d6b G*5b G*4b 5b6b 7a6b 3b3a G*4a 3a1a R*7a L*6f 7c7d 6f6c+ 7b8b 6c6b 7d7e 6b7a 8b7a S*7c 8a7c B*6c S*7b B*7d 7b6c 7d6c+ B*7b 1a4a 4b4a G*6b 7a8b 6c7b 8b9c B*8b 9c8d 7b7c 8d8e S*8f
*/

    moves = CustomNotationConverter().movesFromFile(game);
    gameBoard = ShogiUtils.initialBoard;

    playSequence();
  }

  Future<void> playSequence() async {
    final duration = Duration(seconds: 2);

    await Future.delayed(duration);

    for (final move in moves) {
      if (!mounted) {
        return;
      }

      setState(
            () => gameBoard = GameEngine.makeMove(gameBoard, move),
      );

      await Future.delayed(duration);
    }

    if (!mounted) {
      return;
    }

    setState(
          () => gameBoard = ShogiUtils.sfenStringToGameBoard(
          '9/9/9/9/9/2PPP4/PPSG5/1KGB5/LN7 b -'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ShogiBoard(
            gameBoard: gameBoard,
            showPiecesInHand: false,
          ),
        ),
      ),
    );
  }
}

class _Tsume extends StatelessWidget {
  const _Tsume({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameBoard = ShogiUtils.sfenStringToGameBoard(
        '9/9/4+R4/7kS/9/8g/9/9/9 b GSr2b2g2s4n4l18p');

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ShogiBoard(
            gameBoard: gameBoard,
            style: ShogiBoardStyle(
              cellColor: BoardColors.brown,
              showCoordIndicators: false,
            ),
          ),
        ),
      ),
    );
  }
}

class _Proverb extends StatelessWidget {
  const _Proverb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avoid a Sitting King'),
      ),
      body: SafeArea(
        child: DefaultShogiBoardStyle(
          style: ShogiBoardStyle(
            // maxSize: 400,
            coordIndicatorType: CoordIndicatorType.arabic,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 16),
                  Text(
                      'It is extremely dangerous to start fighting with the King sitting on the original square. In Diagram 1, Black has already advanced a Silver onto 4f with his King in the original position. If he wants to launch an attack from here, how would he play?'),
                  Container(height: 16),
                  _SFENBoard(
                    sfenString:
                    'l3kgsnl/9/p1pS+Bp3/7pp/6PP1/9/PPPPPPn1P/1B1GG2+r1/LNS1K3L w RG3Psnp',
                    label: 'Diagram 1',
                    // showPiecesInHand: false,
                  ),
                  Container(height: 16),
                  _MovesList(
                    moves: [
                      'P-3e',
                      'Px3e',
                      'Sx3e',
                      'P*3d',
                      'P-2d',
                      'Px2d',
                      'Sx2d',
                      'Sx2d',
                      'Bx2d',
                      'Bx2d',
                      'Rx2d',
                    ],
                    playerFirstMove: PlayerType.sente,
                  ),
                  Container(height: 16),
                  _SFENBoard(
                    sfenString:
                    'ln3k1nl/1r4g2/p1ppsg2p/1p2pppR1/9/2PPP4/PPS2P2P/2G1G4/LN2K2NL b bspBS2P',
                    label: 'Diagram 2',
                    showPiecesInHand: true,
                  ),
                  Container(height: 16),
                  Text(
                    '''So far, Black's climbing Silver appears to have made a point. But White has a devastating move to play here.''',
                  ),
                  Container(height: 8),
                  _MovesList(
                    moves: [
                      'B*1e',
                    ],
                    playerFirstMove: PlayerType.gote,
                  ),
                  Container(height: 8),
                  Text(
                      'You cannot be too careful when you have a sitting King. Black had to play K6i first in this case. Then the attack would have been successful.'),
                  Container(height: 8),
                  Text(
                    'Content taken from http://www.shogi.net/kakugen/.',
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                  Container(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SFENBoard extends StatelessWidget {
  final String sfenString;
  final String? label;
  final bool showPiecesInHand;

  const _SFENBoard({
    required this.sfenString,
    this.label,
    this.showPiecesInHand = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          ShogiBoard(
            gameBoard: ShogiUtils.sfenStringToGameBoard(sfenString),
            showPiecesInHand: showPiecesInHand,
          ),
          if (label != null)
            Column(
              children: <Widget>[
                if (!showPiecesInHand) Container(height: 4),
                Text(label!),
              ],
            ),
        ],
      ),
    );
  }
}

class _MovesList extends StatelessWidget {
  final List<String> moves;
  final PlayerType playerFirstMove;

  const _MovesList({
    required this.moves,
    this.playerFirstMove = PlayerType.sente,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        children: <Widget>[
          for (int i = 0; i < moves.length; i++)
            Text(
              (i % 2 == 0 && playerFirstMove == PlayerType.sente
                  ? BoardConfig.sente
                  : BoardConfig.gote) +
                  moves[i],
              style: TextStyle(
                color: BoardColors.black,
              ),
            ),
        ],
      ),
    );
  }
}
