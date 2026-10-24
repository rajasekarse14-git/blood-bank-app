import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Wraps the entire Flutter application in an authentic smartphone frame
/// when viewed on desktop browsers (width > 600px).
/// On mobile devices and small screens, it seamlessly expands to 100% full-width.
class ResponsiveMobileShell extends StatefulWidget {
  final Widget child;

  const ResponsiveMobileShell({super.key, required this.child});

  @override
  State<ResponsiveMobileShell> createState() => _ResponsiveMobileShellState();
}

class _ResponsiveMobileShellState extends State<ResponsiveMobileShell> {
  bool _forceFullScreen = false;

  @override
  Widget build(BuildContext context) {
    // Only apply desktop phone simulator shell on Web or desktop platforms with wide screens
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideDesktop = kIsWeb && screenWidth > 640 && !_forceFullScreen;

    if (!isWideDesktop) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
      body: Stack(
        children: [
          // Ambient background decoration
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                      : [const Color(0xFFF1F5F9), const Color(0xFFCBD5E1)],
                ),
              ),
            ),
          ),

          // Top control bar for desktop users
          Positioned(
            top: 12,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_iphone_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'HemoLife 2.0 Mobile View',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _forceFullScreen = true;
                    });
                  },
                  icon: const Icon(Icons.fullscreen_rounded, size: 18),
                  label: const Text('Expand Fullscreen', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Centered Smartphone Frame
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              width: 412,
              height: 870,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(46),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 36,
                    spreadRadius: 4,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(42),
                child: Stack(
                  children: [
                    // The Flutter Mobile App Content
                    Positioned.fill(
                      child: widget.child,
                    ),

                    // Smartphone Dynamic Island / Speaker Pill
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 110,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E293B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 34,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF334155),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
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
}
