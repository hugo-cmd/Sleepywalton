import 'package:flutter/material.dart';
import '../models/models.dart';

class SleepChart extends StatelessWidget {
  final List<SleepLog> sleepLogs;

  const SleepChart({
    super.key,
    required this.sleepLogs,
  });

  @override
  Widget build(BuildContext context) {
    if (sleepLogs.isEmpty) {
      return Center(
        child: Text(
          'No data to display',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }

    // Get the last 7 days of data
    final last7Days = _getLast7Days();
    final maxHours = _getMaxSleepHours(last7Days);

    return CustomPaint(
      painter: SleepChartPainter(
        sleepLogs: last7Days,
        maxHours: maxHours,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Container(),
    );
  }

  List<SleepLog?> _getLast7Days() {
    final now = DateTime.now();
    final List<SleepLog?> last7Days = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final log = sleepLogs.firstWhere(
        (log) => log.date.day == date.day && 
                 log.date.month == date.month && 
                 log.date.year == date.year,
        orElse: () => throw StateError('No log found'),
      );
      
      try {
        last7Days.add(log);
      } catch (e) {
        last7Days.add(null);
      }
    }

    return last7Days;
  }

  double _getMaxSleepHours(List<SleepLog?> logs) {
    double maxHours = 8.0; // Default to 8 hours
    
    for (final log in logs) {
      if (log?.sleepDuration != null) {
        final hours = log!.sleepDuration!.inMinutes / 60.0;
        if (hours > maxHours) {
          maxHours = hours;
        }
      }
    }
    
    return maxHours;
  }
}

class SleepChartPainter extends CustomPainter {
  final List<SleepLog?> sleepLogs;
  final double maxHours;
  final Color color;

  SleepChartPainter({
    required this.sleepLogs,
    required this.maxHours,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw grid lines
    _drawGridLines(canvas, size, textPainter);

    // Draw sleep bars
    _drawSleepBars(canvas, size, paint, fillPaint, textPainter);
  }

  void _drawGridLines(Canvas canvas, Size size, TextPainter textPainter) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );

      // Draw hour labels
      final hours = maxHours * (4 - i) / 4;
      textPainter.text = TextSpan(
        text: '${hours.toStringAsFixed(1)}h',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width - 8, y - textPainter.height / 2),
      );
    }
  }

  void _drawSleepBars(Canvas canvas, Size size, Paint paint, Paint fillPaint, TextPainter textPainter) {
    final barWidth = size.width / sleepLogs.length;
    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    for (int i = 0; i < sleepLogs.length; i++) {
      final log = sleepLogs[i];
      final x = i * barWidth + barWidth / 2;
      
      if (log?.sleepDuration != null) {
        final hours = log!.sleepDuration!.inMinutes / 60.0;
        final barHeight = (hours / maxHours) * size.height;
        final y = size.height - barHeight;

        // Draw bar
        final rect = Rect.fromLTWH(
          x - barWidth * 0.3,
          y,
          barWidth * 0.6,
          barHeight,
        );

        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, paint);

        // Draw value on top of bar
        textPainter.text = TextSpan(
          text: '${hours.toStringAsFixed(1)}h',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height - 4),
        );
      } else {
        // Draw empty bar
        final rect = Rect.fromLTWH(
          x - barWidth * 0.3,
          size.height - 10,
          barWidth * 0.6,
          10,
        );

        canvas.drawRect(rect, Paint()..color = Colors.grey.withOpacity(0.3));
      }

      // Draw day labels
      textPainter.text = TextSpan(
        text: dayNames[i],
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
