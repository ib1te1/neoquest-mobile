import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText({
    Key? key,
    required this.text,
    required this.style,
    required this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(text, style: style),
    );
  }
}

class WavePainter extends CustomPainter {
  final Gradient gradient;

  WavePainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    const double amplitude = 250.0;
    const double frequency = 2.5;
    const double verticalOffset = -80.0;

    path.moveTo(0, size.height / 2 + verticalOffset);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 + verticalOffset + amplitude * sin(2 * pi * frequency * x / size.width);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class TimelineEvent {
  final String year, title, description;
  TimelineEvent({required this.year, required this.title, required this.description});
}

class HistoryScreen extends StatelessWidget {
  HistoryScreen({Key? key}) : super(key: key);

  // Список событий
  final List<TimelineEvent> events = [
    TimelineEvent(
      year: '2005',
      title: 'Основание компании',
      description:
      'Группа менеджеров создала Neoflex, начав сотрудничество с IBM и SAP. Первые проекты в Сбербанке, СДМ-Банке и BNP Paribas.',
    ),
    TimelineEvent(
      year: '2008',
      title: 'Разработка собственных продуктов',
      description:
      'Формулирование стратегии, запуск Neoflex FrontOffice и Neoflex Reporting. Статус IBM Premier Business Partner.',
    ),
    TimelineEvent(
      year: '2012',
      title: 'Международное расширение',
      description:
      'Neoflex запускает интеграционные проекты с Oracle SOA Suite и Microsoft BizTalk, расширяя присутствие на зарубежных рынках.',
    ),
    TimelineEvent(
      year: '2016',
      title: 'Big Data и международное признание',
      description:
      'Начало работы с Big Data, IoT и микросервисами, открытие представительства в Гонконге.',
    ),
    TimelineEvent(
      year: '2023',
      title: 'Новый стратегический этап',
      description:
      'Фокус на Data Science и мобильной разработке, укрепление международных партнёрств.',
    ),
  ];

  final Gradient headerGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFD2005A), Color(0xFFE63B31), Color(0xFFFF9F18)],
    stops: [0, 0.48, 1],
  );
  final Gradient circleGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF821363), Color(0xFFD2005A), Color(0xFFE63B31), Color(0xFFFF9F18)],
    stops: [0.0021, 0.3006, 0.5991, 0.9067],
  );
  final Gradient textGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF821363),
      Color(0xFFD2005A),
      Color(0xFFE63B31),
      Color(0xFFFF9F18)
    ],
    stops: [0.0146, 0.0829, 0.1521, 0.2229],
  );

  final List<double> topOffsets = [560, 70, 540, 60, 550];

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 340;
    const double cardMargin = 48;
    final double totalWidth = events.length * (cardWidth + cardMargin);
    final double canvasHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF140033),
      appBar: AppBar(
        backgroundColor: const Color(0xFF140033),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const SizedBox.shrink(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: GradientText(
              text: 'История компании',
              style: AppTextStyles.subtitle.copyWith(fontSize: 30),
              gradient: headerGradient,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalWidth,
                height: canvasHeight,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(totalWidth, canvasHeight),
                      painter: WavePainter(gradient: circleGradient),
                    ),
                    Positioned.fill(
                      child: Row(
                        children: List.generate(events.length, (i) {
                          final ev = events[i];
                          final double topOffset = topOffsets[i];
                          return Container(
                            width: cardWidth,
                            margin: const EdgeInsets.only(right: cardMargin),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  top: topOffset,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF17003C),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ev.title,
                                            style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
                                        const SizedBox(height: 12),
                                        RichText(
                                          text: TextSpan(
                                            style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 14),
                                            children: _buildDescriptionSpans(ev.description),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: topOffset - 30,
                                  left: (cardWidth / 2) - 30,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: circleGradient,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(ev.year,
                                        style: AppTextStyles.subtitle.copyWith(
                                          fontSize: 16,
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _buildDescriptionSpans(String text) {
    final List<InlineSpan> spans = [];
    final pattern = RegExp(r'Neoflex');
    int start = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(WidgetSpan(
        child: GradientText(
          text: match.group(0)!,
          style: AppTextStyles.body.copyWith(fontSize: 14),
          gradient: textGradient,
        ),
      ));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return spans;
  }
}
