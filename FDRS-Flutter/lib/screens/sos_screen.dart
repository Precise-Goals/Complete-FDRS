import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/service_locator.dart';
import '../theme/app_theme.dart';
import '../app_router.dart';
import '../services/navigation_service.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fillController;
  late AnimationController _waveController;
  final LocationService _locationService = locator<LocationService>();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fillController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _sendSOS();
      }
    });

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fillController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _sendSOS() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await _locationService.sendSOS(authService.user?.uid);

    if (!mounted) return;

    switch (result) {
      case SosResult.success:
        Vibration.hasVibrator().then((hasVibrator) {
          if (hasVibrator == true) {
            Vibration.vibrate(duration: 1000);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS Triggered! Location broadcasted.'),
            backgroundColor: Colors.red,
          ),
        );
        break;
      case SosResult.sentViaRadio:
        Vibration.hasVibrator().then((hasVibrator) {
          if (hasVibrator == true) {
            Vibration.vibrate(duration: 1000);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS sent via Radio Link.'),
            backgroundColor: Colors.amber,
          ),
        );
        break;
      case SosResult.queued:
        Vibration.hasVibrator().then((hasVibrator) {
          if (hasVibrator == true) {
            Vibration.vibrate(duration: 500);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No connectivity — SOS queued. It will auto-send when you\'re back online.'),
            backgroundColor: Colors.amber,
            duration: Duration(seconds: 5),
          ),
        );
        break;
      case SosResult.permissionDenied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permission denied. Please grant location access in Settings.'),
            backgroundColor: Colors.amber,
          ),
        );
        break;
      case SosResult.locationDisabled:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location service is disabled. Please enable GPS.'),
            backgroundColor: Colors.amber,
          ),
        );
        break;
      case SosResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send SOS. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentRed.withAlpha(13),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.accentRed.withValues(alpha: 0.2),
                        blurRadius: 100,
                        spreadRadius: -100)
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[900]?.withAlpha(13),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blue[900]!.withOpacity(0.25),
                        blurRadius: 100,
                        spreadRadius: -50)
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FDRS',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                  ),
                            ),
                            const Text(
                              'SYSTEM ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        _buildLoginButton(authService),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                  Column(
                    children: [
                      Text(
                        'Emergency?',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.normal,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap below to broadcast location\nto NDRF & CRPF units.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: 256,
                        height: 256,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: 240,
                                height: 240,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.orange.withAlpha(51),
                                      width: 1),
                                ),
                              ),
                            ),
                            ScaleTransition(
                              scale: Tween<double>(begin: 1.05, end: 1.25)
                                  .animate(_pulseController),
                              child: Container(
                                width: 240,
                                height: 240,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.orange.withAlpha(26),
                                      width: 1),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTapDown: (_) {
                                _pulseController.stop();
                                _fillController.forward();
                              },
                              onTapUp: (_) {
                                if (!_fillController.isCompleted) {
                                  _fillController.reverse();
                                }
                                _pulseController.repeat(reverse: true);
                              },
                              onTapCancel: () {
                                if (!_fillController.isCompleted) {
                                  _fillController.reverse();
                                }
                                _pulseController.repeat(reverse: true);
                              },
                              child: Container(
                                width: 192,
                                height: 192,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF8C00),
                                      Color(0xFFD35400)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                      color: const Color(0x99FFC896)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x4DFF8C00),
                                      blurRadius: 40,
                                    ),
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 20,
                                      offset: Offset(0, 0),
                                      blurStyle: BlurStyle.inner,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AnimatedBuilder(
                                      animation: Listenable.merge(
                                          [_fillController, _waveController]),
                                      builder: (context, child) {
                                        return Positioned.fill(
                                          child: ClipPath(
                                            clipper: WaterClipper(
                                              fillLevel: _fillController.value,
                                              wavePhase: _waveController.value *
                                                  2 *
                                                  math.pi,
                                            ),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF2A2A),
                                                    Color(0xFF8B0000)
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Positioned(
                                      top: 24,
                                      right: 40,
                                      child: Transform.rotate(
                                        angle: -0.43,
                                        child: Container(
                                          width: 64,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                255, 255, 255, 0.4),
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'SOS',
                                          style: AppTheme.techFont.copyWith(
                                            fontSize: 60,
                                            color: Colors.white,
                                            shadows: [
                                              const Shadow(
                                                color: Colors.black26,
                                                blurRadius: 20,
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'HOLD 2S',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white70,
                                            letterSpacing: 2.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: _buildStatusCard(Icons.radio_outlined,
                                'Radio Link', 'Active', Colors.green)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildStatusCard(
                                Icons.satellite_alt_outlined,
                                'Satellite',
                                'Connected',
                                Colors.blue)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoginButton(AuthService authService) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.panelGray,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: IconButton(
        icon: Icon(authService.isLoggedIn ? Icons.logout : Icons.login,
            color: Colors.white, size: 20),
        onPressed: () {
          if (authService.isLoggedIn) {
            authService.signOut();
          } else {
            locator<NavigationService>().navigateTo(AppRouter.loginRoute);
          }
        },
      ),
    );
  }

  Widget _buildStatusCard(
      IconData icon, String title, String status, Color dotColor) {
    return Container(
      height: 128,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.grey[400]),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: dotColor.withAlpha(204), blurRadius: 8),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WaterClipper extends CustomClipper<Path> {
  final double fillLevel; // 0.0 to 1.0 (empty to full)
  final double wavePhase; // 0.0 to 2*pi

  WaterClipper({required this.fillLevel, required this.wavePhase});

  @override
  Path getClip(Size size) {
    if (fillLevel == 0.0) {
      return Path();
    }
    final path = Path();
    final waterLevel = (1 - fillLevel) * size.height;

    path.moveTo(0, size.height);
    path.lineTo(0, waterLevel);

    // Sine wave
    for (double i = 0; i <= size.width; i++) {
      // Wave amplitude is proportional to the fill level? Or constant. Let's use 8.0.
      // It looks best when we have some dynamic variance.
      double amplitude = (fillLevel == 0.0 || fillLevel == 1.0) ? 0.0 : 8.0;
      double waveHeight =
          amplitude * math.sin((i / size.width * 2 * math.pi) + wavePhase);
      path.lineTo(i, waterLevel + waveHeight);
    }

    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaterClipper oldClipper) =>
      oldClipper.fillLevel != fillLevel || oldClipper.wavePhase != wavePhase;
}
