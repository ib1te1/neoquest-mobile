// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class TimelineEvent {
  final String year;
  final String title;
  final String description;
  final String detailedDescription; // Подробное описание для диалога
  final String imagePath; // путь к локальному изображению (например, 'assets/event1.jpg')

  TimelineEvent({
    required this.year,
    required this.title,
    required this.description,
    required this.detailedDescription,
    required this.imagePath,
  });
}

class HistoryScreen extends StatelessWidget {
  HistoryScreen({Key? key}) : super(key: key);

  // Пример данных для 5 событий
  final List<TimelineEvent> events = [
    TimelineEvent(
      year: '2005',
      title: 'Основание компании',
      description:
      'Группа менеджеров создала Neoflex, начав сотрудничество с IBM и SAP. Первые проекты в Сбербанке, СДМ-Банке и BNP Paribas.',
      detailedDescription:
      'В феврале 2005 года опытная группа менеджеров, специализирующихся на автоматизации банковской деятельности, создала компанию Neoflex. В результате компания стала партнером IBM и SAP, стартовали первые проекты в Сбербанке, СДМ-Банке и BNP Paribas. Всего было выполнено 18 проектов для 9 клиентов.',
      imagePath: 'assets/sample1.jpg',
    ),
    TimelineEvent(
      year: '2008',
      title: 'Разработка собственных продуктов',
      description:
      'Сформулирована стратегия, началась разработка Neoflex FrontOffice и Neoflex Reporting. Компания достигла статуса IBM Premier Business Partner.',
      detailedDescription:
      'В 2008 году была сформулирована продуктовая стратегия компании. Началась разработка собственных программных продуктов – Neoflex FrontOffice и система Neoflex Reporting для автоматизации формирования обязательной банковской отчетности. Компания получила высший партнерский статус IBM Premier Business Partner, численность сотрудников достигла 100, а выполнено было 117 проектов для 27 клиентов.',
      imagePath: 'assets/sample2.jpg',
    ),
    TimelineEvent(
      year: '2012',
      title: 'Международное расширение',
      description:
      'Neoflex запускает интеграционные проекты с Oracle SOA Suite и Microsoft BizTalk, расширяя присутствие на зарубежных рынках.',
      detailedDescription:
      'В 2012 году Neoflex уверенно рос, расширяя свою продуктовую линейку и налаживая партнерство на международном уровне. В банке ВТБ24 стартует первый интеграционный проект с использованием Oracle SOA Suite, а также реализуются проекты для BMW Bank на платформе Microsoft BizTalk. Компания становится единственным в России партнером GoldenSource и ведет проекты по внедрению систем Securities&Products в Сбербанке.',
      imagePath: 'assets/sample3.jpg',
    ),
    TimelineEvent(
      year: '2016',
      title: 'Big Data и международное признание',
      description:
      'Начало работы с Big Data, IoT и микросервисами, открытие представительства в Гонконге, международное признание.',
      detailedDescription:
      'В 2016 году Neoflex начинает реализовывать проекты с использованием технологий Big Data, IoT и микросервисной архитектуры. Компания расширяет свое присутствие на новых вертикальных рынках, открывает представительство в Гонконге для работы с рынками Юго-Восточной Азии, и завоевывает доверие зарубежных клиентов, успешно реализуя крупные проекты для иностранных банков.',
      imagePath: 'assets/sample4.jpg',
    ),
    TimelineEvent(
      year: '2023',
      title: 'Новый стратегический этап',
      description:
      'Компания переходит на новый уровень развития: расширение экспертизы в Data Science и мобильной разработке, новые партнерства.',
      detailedDescription:
      'В 2023 году фокус компании Neoflex смещается в сторону развития инновационных бизнес-решений, расширяются направления Data Science, мобильной разработки и укрепляются международные партнерства. Это новый стратегический этап, который позволяет компании успешно адаптироваться к быстро меняющемуся рынку и задавать новые стандарты в ИТ-сфере.',
      imagePath: 'assets/sample5.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text('Company History', style: AppTextStyles.subtitle),
        backgroundColor: AppColors.violet,
        centerTitle: true,
      ),
      // Центрирование контента по вертикали и горизонтали
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(events.length, (index) {
              final event = events[index];
              final isTop = index % 2 == 0;
              return _TimelineItem(
                event: event,
                isTop: isTop, // Если индекс чётный — текст сверху, иначе снизу
                isLast: index == events.length - 1,
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Виджет для одной «точки» на таймлайне
class _TimelineItem extends StatelessWidget {
  final TimelineEvent event;
  final bool isTop; // Если true — текстовой блок сверху, иначе снизу
  final bool isLast;

  const _TimelineItem({
    Key? key,
    required this.event,
    required this.isTop,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Размеры блока
    const double itemWidth = 300;
    const double itemHeight = 550;
    // Отступ от центральной линии (таймлайна)
    const double timelinePadding = 30.0;
    // Вычисляем доступную высоту для текстового блока (верхняя и нижняя части равны)
    final double textBlockHeight = (itemHeight / 2) - timelinePadding;

    return SizedBox(
      width: itemWidth,
      height: itemHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Центровая линия таймлайна с треугольной стрелкой
          Positioned.fill(
            child: CustomPaint(
              painter: _TimelineLinePainter(isLast: isLast),
            ),
          ),
          // Кружок с годом, располагается ровно по центру вертикально
          Positioned(
            top: itemHeight / 2 - 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.violet,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                event.year,
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (isTop) ...[
            // Верхний вариант: текстовый блок в верхней части,
            // а изображение — в нижней
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: textBlockHeight,
              child: _TextBox(
                title: event.title,
                description: event.description,
                detailedDescription: event.detailedDescription,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              // Изображение располагается в нижней половине без ограничений,
              // так как его высота (140) меньше отведённого пространства
              height: itemHeight / 2,
              child: _ImageBox(imagePath: event.imagePath),
            ),
          ] else ...[
            // Нижний вариант: изображение в верхней части, а текст — в нижней
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: itemHeight / 2,
              child: _ImageBox(imagePath: event.imagePath),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: itemHeight / 2 + timelinePadding,
              height: textBlockHeight,
              child: _TextBox(
                title: event.title,
                description: event.description,
                detailedDescription: event.detailedDescription,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Отрисовка горизонтальной линии с треугольной стрелкой (для последнего события)
class _TimelineLinePainter extends CustomPainter {
  final bool isLast;

  _TimelineLinePainter({required this.isLast});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final paint = Paint()
      ..color = AppColors.cyan
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Рисуем горизонтальную линию
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint,
    );

    // Если это последнее событие — рисуем заполненную стрелку (треугольник)
    if (isLast) {
      final arrowSize = 10.0;
      final arrowPath = Path();
      arrowPath.moveTo(size.width, centerY);
      arrowPath.lineTo(size.width - arrowSize, centerY - arrowSize);
      arrowPath.lineTo(size.width - arrowSize, centerY + arrowSize);
      arrowPath.close();
      final fillPaint = Paint()..color = AppColors.cyan;
      canvas.drawPath(arrowPath, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Контейнер для изображения события
class _ImageBox extends StatelessWidget {
  final String imagePath;
  const _ImageBox({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Если изображение грузится из сети, замените Image.asset на Image.network
    return Container(
      margin: const EdgeInsets.all(8),
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.violet.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violet.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// Контейнер для заголовка и описания с обработкой нажатия
class _TextBox extends StatelessWidget {
  final String title;
  final String description;
  final String detailedDescription;

  const _TextBox({
    Key? key,
    required this.title,
    required this.description,
    required this.detailedDescription,
  }) : super(key: key);

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.dark,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: AppColors.violet.withOpacity(0.4)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                child: Text(
                  detailedDescription,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                    AppColors.violet.withOpacity(0.2),
                    foregroundColor: AppColors.cyan,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Закрыть'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Оборачиваем содержимое в SingleChildScrollView для возможности прокрутки,
    // если текст превышает отведённое пространство
    return GestureDetector(
      onTap: () => _showDetailDialog(context),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.violet.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.violet.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок без ограничения по числу строк
              Text(
                title,
                style: AppTextStyles.subtitle,
                softWrap: true,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
