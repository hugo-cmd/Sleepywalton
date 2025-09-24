import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/services.dart';
import 'alarm_list_screen.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final List<String> _enteredPin = [];
  List<String> _confirmPinList = [];
  bool _isConfirming = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin.add(number);
        _errorMessage = null;
      });
      
      HapticFeedback.lightImpact();
      
      if (_enteredPin.length == 4) {
        if (!_isConfirming) {
          _startConfirmation();
        } else {
          _confirmPin();
        }
      }
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
        _errorMessage = null;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _startConfirmation() {
    setState(() {
      _confirmPinList = List.from(_enteredPin);
      _enteredPin.clear();
      _isConfirming = true;
    });
  }

  Future<void> _confirmPin() async {
    if (_enteredPin.join('') == _confirmPinList.join('')) {
      setState(() => _isLoading = true);
      
      try {
        // Set the PIN
        final success = await AuthService.setPin(_enteredPin.join(''));
        
        if (success) {
          // Enable biometric authentication if available
          final isBiometricAvailable = await AuthService.isBiometricAvailable();
          if (isBiometricAvailable) {
            await _showBiometricSetup();
          } else {
            await _completeSetup();
          }
        } else {
          setState(() {
            _errorMessage = 'Failed to set PIN. Please try again.';
            _enteredPin.clear();
            _confirmPinList.clear();
            _isConfirming = false;
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: $e';
          _enteredPin.clear();
          _confirmPinList.clear();
          _isConfirming = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'PINs do not match. Please try again.';
        _enteredPin.clear();
        _confirmPinList.clear();
        _isConfirming = false;
      });
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _showBiometricSetup() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Biometric Authentication'),
        content: const Text(
          'Would you like to enable biometric authentication (Face ID/Touch ID) for easier alarm dismissal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (result == true) {
      await AuthService.setBiometricEnabled(true);
    }

    await _completeSetup();
  }

  Future<void> _completeSetup() async {
    // Mark setup as complete
    await AuthService.markSetupComplete();
    
    // Navigate to main app
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AlarmListScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Set Up Security'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isConfirming ? 'Confirm Your PIN' : 'Create Your PIN',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isConfirming 
                          ? 'Enter your PIN again to confirm'
                          : 'Choose a 4-digit PIN to secure your alarm dismissal',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // PIN display
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < _enteredPin.length
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        );
                      }),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
              
              // Number pad
              Expanded(
                flex: 3,
                child: _buildNumberPad(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildEmptyButton(),
              _buildNumberButton('0'),
              _buildBackspaceButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: _isLoading ? null : () => _onNumberPressed(number),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            elevation: 2,
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _onBackspacePressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            elevation: 2,
          ),
          child: const Icon(
            Icons.backspace_outlined,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyButton() {
    return const Expanded(
      child: SizedBox(),
    );
  }
}
