import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  final String title;
  final String? highlightText;
  final String description;
  final bool showAlert;
  final bool showRadar;
  final bool showMap;
  final bool showBadge;
  final bool isLast;

  const OnboardingPage({
    super.key,
    required this.title,
    this.highlightText,
    required this.description,
    this.showAlert = false,
    this.showRadar = false,
    this.showMap = false,
    this.showBadge = false,
    this.isLast = false,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if (widget.showAlert) _buildAlertBanner(),
          if (widget.showRadar) _buildRadarAnimation(),
          if (widget.showMap) _buildMapPreview(),
          if (widget.showBadge) _buildBadgeImage(),
          const SizedBox(height: 32),
          _buildTitle(),
          const SizedBox(height: 16),
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALERT',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'SOS Signal Detected',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarAnimation() {
    return AnimatedBuilder(
      animation: _radarController,
      builder: (context, child) {
        return SizedBox(
          height: 180,
          child: CustomPaint(
            painter: RadarPainter(progress: _radarController.value),
            size: const Size(180, 180),
          ),
        );
      },
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceLight,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildMapPlaceholder(),
          ),
          Positioned(
            left: 24,
            top: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Viện Huyết học - Truyền máu Trung ương',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceLight,
            AppColors.surface,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
              'Bản đồ điểm hiến máu',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeImage() {
    return Container(
      width: 180,
      height: 180,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primaryDark,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.workspace_premium,
              size: 80,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    if (widget.highlightText != null) {
      final parts = widget.title.split(widget.highlightText!);
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          children: [
            TextSpan(text: parts[0]),
            TextSpan(
              text: widget.highlightText,
              style: const TextStyle(color: AppColors.primary),
            ),
            if (parts.length > 1) TextSpan(text: parts[1]),
          ],
        ),
      );
    }
    return Text(
      widget.title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double progress;

  RadarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 1; i <= 4; i++) {
      final radius = (size.width / 2) * (i / 4);
      final paint = Paint()
        ..color = AppColors.primary.withOpacity(0.2 - i * 0.04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, radius, paint);
    }
    final sweepAngle = 2 * math.pi * progress;
    final gradientPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + sweepAngle,
        colors: [
          AppColors.primary.withOpacity(0.6),
          AppColors.primary.withOpacity(0.1),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2),
      -math.pi / 2,
      sweepAngle,
      true,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
