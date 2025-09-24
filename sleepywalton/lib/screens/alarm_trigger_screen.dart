import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'auth_screen.dart';

class AlarmTriggerScreen extends ConsumerStatefulWidget {
  final Alarm alarm;

  const AlarmTriggerScreen({
    super.key,
    required this.alarm,
  });

  @override
  ConsumerState<AlarmTriggerScreen> createState() => _AlarmTriggerScreenState();
}

class _AlarmTriggerScreenState extends ConsumerState<AlarmTriggerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  
  Timer? _alarmTimer;
  DateTime? _alarmStartTime;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _alarmStartTime = DateTime.now();
    
    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _startAlarm();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _alarmTimer?.cancel();
    super.dispose();
  }

  void _startAlarm() {
    // Start pulse animation
    _pulseController.repeat(reverse: true);
    
    // Start shake animation periodically
    _startShakeTimer();
    
    // Vibrate if enabled
    if (widget.alarm.isVibrationEnabled) {
      _startVibration();
    }
    
    // Play alarm sound (in a real app, you'd use audioplayers)
    _playAlarmSound();
  }

  void _startShakeTimer() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isDismissed) {
        _shakeController.forward().then((_) {
          _shakeController.reverse();
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startVibration() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isDismissed) {
        HapticFeedback.heavyImpact();
      } else {
        timer.cancel();
      }
    });
  }

  void _playAlarmSound() {
    // In a real app, you would use audioplayers to play the alarm sound
    // For now, we'll just show a message
    print('Playing alarm sound: ${widget.alarm.soundPath}');
  }

  Future<void> _dismissAlarm() async {
    if (_isDismissed) return;
    
    setState(() => _isDismissed = true);
    
    // Stop animations
    _pulseController.stop();
    _shakeController.stop();
    
    // Calculate wake latency
    final wakeLatency = _alarmStartTime != null 
        ? DateTime.now().difference(_alarmStartTime!).inSeconds
        : 0;
    
    // Dismiss the alarm
    await AlarmService.dismissAlarm(
      widget.alarm.id,
      method: widget.alarm.dismissalMethod,
      wakeLatencySeconds: wakeLatency,
    );
    
    // Navigate back to alarm list
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _showEmergencyUnlock() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(
          title: 'Emergency Unlock',
          subtitle: 'Enter your PIN or use biometric authentication to dismiss the alarm',
        ),
      ),
    );
    
    if (result == true) {
      await _dismissAlarm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button from dismissing alarm
      child: Scaffold(
        backgroundColor: _getBackgroundColor(),
        body: SafeArea(
          child: Column(
            children: [
              // Top section with alarm info
              Expanded(
                flex: 2,
                child: _buildAlarmInfo(),
              ),
              
              // Center section with time and instructions
              Expanded(
                flex: 3,
                child: _buildCenterSection(),
              ),
              
              // Bottom section with emergency unlock
              Expanded(
                flex: 1,
                child: _buildBottomSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.alarm.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.alarm.repeatDaysText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large time display with pulse animation
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: Text(
                      _getCurrentTime(),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 72,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        
        const SizedBox(height: 32),
        
        // Dismissal instructions
        _buildDismissalInstructions(),
      ],
    );
  }

  Widget _buildDismissalInstructions() {
    if (widget.alarm.dismissalMethod == DismissalMethod.nfc) {
      return Column(
        children: [
          Icon(
            Icons.nfc,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'Tap NFC Tag to Dismiss',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hold your registered NFC tag near the device',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          GestureDetector(
            onTap: _dismissAlarm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                'TAP TO DISMISS',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Or use emergency unlock below',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _showEmergencyUnlock,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.security,
                  size: 20,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 8),
                const Text('Emergency Unlock'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    // Create a gradient background that changes based on time
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 8) {
      // Sunrise colors
      return const Color(0xFFFF6B35); // Orange-red
    } else if (hour >= 8 && hour < 12) {
      // Morning colors
      return const Color(0xFF4ECDC4); // Teal
    } else if (hour >= 12 && hour < 17) {
      // Afternoon colors
      return const Color(0xFF45B7D1); // Blue
    } else if (hour >= 17 && hour < 20) {
      // Evening colors
      return const Color(0xFF96CEB4); // Green
    } else {
      // Night colors
      return const Color(0xFF2C3E50); // Dark blue
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
