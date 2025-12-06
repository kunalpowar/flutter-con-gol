import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'main.dart' show chaosVelocity;

// ---------- Famous patterns (relative coordinates) ----------

const _patterns = <String, List<(int, int)>>{
  // Methuselahs - long-lived patterns
  'R-pentomino': [(1, 0), (2, 0), (0, 1), (1, 1), (1, 2)],
  'Acorn': [(1, 0), (3, 1), (0, 2), (1, 2), (4, 2), (5, 2), (6, 2)],
  'Diehard': [(6, 0), (0, 1), (1, 1), (1, 2), (5, 2), (6, 2), (7, 2)],
  'B-heptomino': [(0, 0), (1, 0), (2, 0), (0, 1), (1, 1), (2, 2), (1, 3)],
  'Pi-heptomino': [(0, 0), (1, 0), (2, 0), (0, 1), (2, 1), (0, 2), (2, 2)],
  'Thunderbird': [(0, 0), (1, 0), (2, 0), (1, 2), (1, 3), (1, 4)],

  // Spaceships
  'Glider': [(1, 0), (2, 1), (0, 2), (1, 2), (2, 2)],
  'LWSS': [
    (1, 0),
    (4, 0),
    (0, 1),
    (0, 2),
    (4, 2),
    (0, 3),
    (1, 3),
    (2, 3),
    (3, 3),
  ],
  'MWSS': [
    (2, 0),
    (0, 1),
    (4, 1),
    (5, 2),
    (0, 3),
    (5, 3),
    (1, 4),
    (2, 4),
    (3, 4),
    (4, 4),
    (5, 4),
  ],
  'HWSS': [
    (2, 0),
    (3, 0),
    (0, 1),
    (5, 1),
    (6, 2),
    (0, 3),
    (6, 3),
    (1, 4),
    (2, 4),
    (3, 4),
    (4, 4),
    (5, 4),
    (6, 4),
  ],

  // Oscillators
  'Blinker': [(0, 0), (1, 0), (2, 0)],
  'Toad': [(1, 0), (2, 0), (3, 0), (0, 1), (1, 1), (2, 1)],
  'Beacon': [(0, 0), (1, 0), (0, 1), (3, 2), (2, 3), (3, 3)],
  'Clock': [(1, 0), (2, 1), (0, 2), (3, 2), (1, 3), (2, 4)],

  // Pulsars and larger oscillators
  'Pulsar-seed': [
    (2, 0),
    (3, 0),
    (4, 0),
    (0, 2),
    (0, 3),
    (0, 4),
    (5, 2),
    (5, 3),
    (5, 4),
    (2, 5),
    (3, 5),
    (4, 5),
  ],

  // Still lifes (for stability)
  'Block': [(0, 0), (1, 0), (0, 1), (1, 1)],
  'Beehive': [(1, 0), (2, 0), (0, 1), (3, 1), (1, 2), (2, 2)],
  'Loaf': [(1, 0), (2, 0), (0, 1), (3, 1), (1, 2), (3, 2), (2, 3)],
  'Boat': [(0, 0), (1, 0), (0, 1), (2, 1), (1, 2)],

  // Interesting small patterns
  'Pentomino-F': [(1, 0), (2, 0), (0, 1), (1, 1), (1, 2)],
  'Pentomino-Y': [(1, 0), (0, 1), (1, 1), (1, 2), (1, 3)],
  'Herschel': [(0, 0), (0, 1), (1, 1), (0, 2), (2, 2), (2, 3)],

  // Multi-glider generators
  'Rabbits': [
    (0, 0),
    (2, 0),
    (4, 0),
    (5, 0),
    (6, 0),
    (0, 1),
    (1, 1),
    (4, 1),
    (1, 2),
  ],
  'Bunnies': [(0, 0), (6, 0), (2, 1), (6, 1), (2, 2), (5, 2), (3, 3), (4, 3)],
};

// ---------- Shared rule model ----------

class LifeRule {
  final Set<int> birth;
  final Set<int> survive;

  const LifeRule({required this.birth, required this.survive});

  factory LifeRule.fromString(String s) {
    final parts = s.split('/');
    Set<int> b = {};
    Set<int> sv = {};

    for (final part in parts) {
      if (part.startsWith('B')) {
        b = part
            .substring(1)
            .split('')
            .where((c) => c.isNotEmpty)
            .map(int.parse)
            .toSet();
      } else if (part.startsWith('S')) {
        sv = part
            .substring(1)
            .split('')
            .where((c) => c.isNotEmpty)
            .map(int.parse)
            .toSet();
      }
    }

    if (b.isEmpty && sv.isEmpty) {
      return const LifeRule(birth: {3}, survive: {2, 3});
    }
    return LifeRule(birth: b, survive: sv);
  }

  @override
  String toString() {
    return 'B${birth.toList()..sort()}/S${survive.toList()..sort()}';
  }
}

// ---------- Universe Screen ----------

class UniverseScreen extends StatefulWidget {
  final int universeId;

  const UniverseScreen({super.key, required this.universeId});

  String get name => 'Universe #$universeId';

  @override
  State<UniverseScreen> createState() => _UniverseScreenState();
}

class _UniverseScreenState extends State<UniverseScreen> {
  static const int rows = 40;
  static const int cols = 60;

  late List<List<int>>
  _cellAge; // 0=dead, 1+=alive age, negative=dying (afterglow)
  late LifeRule _rule;
  Timer? _timer;
  bool _running = true;
  int _generation = 0;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _rule = LifeRule.fromString('B3/S23');
    _cellAge = _randomGrid();
    _start();
    chaosVelocity.addListener(_onVelocityChanged);
  }

  void _onVelocityChanged() => _start();

  @override
  void dispose() {
    chaosVelocity.removeListener(_onVelocityChanged);
    _timer?.cancel();
    super.dispose();
  }

  List<List<int>> _randomGrid() {
    final grid = List.generate(rows, (_) => List<int>.filled(cols, 0));
    final patternKeys = _patterns.keys.toList();

    // Place 4-8 random patterns
    final count = 4 + _rng.nextInt(5);
    for (var i = 0; i < count; i++) {
      final pattern = _patterns[patternKeys[_rng.nextInt(patternKeys.length)]]!;
      final offsetX = 5 + _rng.nextInt(cols - 15);
      final offsetY = 5 + _rng.nextInt(rows - 15);

      for (final (dx, dy) in pattern) {
        final x = offsetX + dx;
        final y = offsetY + dy;
        if (x >= 0 && x < cols && y >= 0 && y < rows) {
          grid[y][x] = 1;
        }
      }
    }
    return grid;
  }

  void _start() {
    _timer?.cancel();
    final ms = (200 / chaosVelocity.value).round().clamp(20, 500);
    _timer = Timer.periodic(Duration(milliseconds: ms), (_) {
      if (!_running) return;
      if (mounted) setState(_step);
    });
  }

  void _toggleRunning() {
    setState(() {
      _running = !_running;
    });
  }

  void _resetRandom() {
    setState(() {
      _cellAge = _randomGrid();
      _generation = 0;
    });
  }

  void _step() {
    final next = List.generate(rows, (_) => List<int>.filled(cols, 0));

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final age = _cellAge[y][x];
        final alive = age > 0;
        int neighbors = 0;

        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue;
            final nx = x + dx;
            final ny = y + dy;
            if (nx < 0 || nx >= cols || ny < 0 || ny >= rows) continue;
            if (_cellAge[ny][nx] > 0) neighbors++;
          }
        }

        final willLive = alive
            ? _rule.survive.contains(neighbors)
            : _rule.birth.contains(neighbors);

        if (willLive) {
          next[y][x] = (age > 0 ? age : 0) + 1; // increment age
        } else if (alive) {
          next[y][x] = -3; // just died, start afterglow
        } else if (age < 0) {
          next[y][x] = age + 1; // fade afterglow
        }
      }
    }

    _cellAge = next;
    _generation++;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Align(alignment: Alignment.topLeft, child: _buildHeader()),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellSize = min(
                  constraints.maxWidth / cols,
                  constraints.maxHeight / rows,
                );
                final width = cellSize * cols;
                final height = cellSize * rows;

                void paintCell(Offset pos) {
                  final x = (pos.dx / cellSize).floor();
                  final y = (pos.dy / cellSize).floor();
                  if (x >= 0 &&
                      x < cols &&
                      y >= 0 &&
                      y < rows &&
                      _cellAge[y][x] <= 0) {
                    setState(() => _cellAge[y][x] = 1);
                  }
                }

                return Center(
                  child: GestureDetector(
                    onPanStart: (d) => paintCell(d.localPosition),
                    onPanUpdate: (d) => paintCell(d.localPosition),
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: CustomPaint(
                        painter: _LifePainter(
                          cellAge: _cellAge,
                          aliveColor: Colors.greenAccent,
                          deadColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Text(
        'Epoch: $_generation',
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FilledButton.tonalIcon(
            onPressed: _toggleRunning,
            icon: Icon(
              _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
            label: Text(
              _running ? 'Freeze Time' : 'Resume Flow',
              style: const TextStyle(fontSize: 15),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: _resetRandom,
            icon: const Icon(Icons.casino_rounded),
            label: const Text('Reset Reality', style: TextStyle(fontSize: 15)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Painter ----------

class _LifePainter extends CustomPainter {
  final List<List<int>> cellAge;
  final Color aliveColor;
  final Color deadColor;

  _LifePainter({
    required this.cellAge,
    required this.aliveColor,
    required this.deadColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rows = cellAge.length;
    final cols = cellAge.first.length;

    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;
    final radius = min(cellWidth, cellHeight) * 0.3;

    final bgPaint = Paint()..color = deadColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final age = cellAge[y][x];
        if (age == 0) continue;

        final rect = Rect.fromLTWH(
          x * cellWidth + 1,
          y * cellHeight + 1,
          cellWidth - 2,
          cellHeight - 2,
        );

        if (age > 0) {
          // Alive cell - scale up if newborn, full size otherwise
          final scale = age == 1 ? 0.7 : 1.0;
          final scaledRect = Rect.fromCenter(
            center: rect.center,
            width: rect.width * scale,
            height: rect.height * scale,
          );
          final rRect = RRect.fromRectAndRadius(
            scaledRect,
            Radius.circular(radius * scale),
          );

          // Glow
          final glowPaint = Paint()
            ..color = aliveColor.withValues(alpha: 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
          canvas.drawRRect(rRect, glowPaint);

          // Cell with slight color variation based on age
          final hue = (age * 2).clamp(0, 20).toDouble();
          final cellColor = HSLColor.fromColor(
            aliveColor,
          ).withHue((140 + hue) % 360).toColor();
          canvas.drawRRect(rRect, Paint()..color = cellColor);
        } else {
          // Dying cell (afterglow) - age is -3, -2, -1
          final fade = (age + 4) / 4; // -3->0.25, -2->0.5, -1->0.75
          final scale = 0.5 + fade * 0.5;
          final scaledRect = Rect.fromCenter(
            center: rect.center,
            width: rect.width * scale,
            height: rect.height * scale,
          );
          final rRect = RRect.fromRectAndRadius(
            scaledRect,
            Radius.circular(radius * scale),
          );

          // Fading glow
          final glowPaint = Paint()
            ..color = aliveColor.withValues(alpha: fade * 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
          canvas.drawRRect(rRect, glowPaint);

          // Fading cell
          canvas.drawRRect(
            rRect,
            Paint()..color = aliveColor.withValues(alpha: fade * 0.6),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LifePainter oldDelegate) {
    return true;
  }
}
