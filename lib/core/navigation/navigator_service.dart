import 'package:flutter/material.dart';

/// Global key to access root navigator state throughout the app.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Safely pop all pushed routes until the root screen is visible.
void popToRoot() {
  rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
}

/// A drop-in replacement for [MaterialPageRoute] that enforces the app-wide
/// horizontal slide transition:
///
///   PUSH — new screen enters from the RIGHT and travels LEFT (RIGHT → LEFT).
///   POP  — current screen exits toward the RIGHT (LEFT → RIGHT), revealing
///           the previous screen that was already beneath it on the stack.
///
/// Usage — replace every:
///   `MaterialPageRoute(builder: (_) => SomeScreen())`
/// with:
///   `SlidePageRoute(builder: (_) => SomeScreen())`
///
/// The [animation] value goes 0 → 1 on push and 1 → 0 on pop, so a single
/// [Tween] from `Offset(1, 0)` to `Offset.zero` naturally handles both
/// directions without any manual logic.
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  /// Duration for both the push-enter and pop-exit transitions.
  static const Duration _kDuration = Duration(milliseconds: 300);

  /// Easing curve — smooth, native-feeling, no bounce.
  static const Curve _kCurve = Curves.easeInOut;

  SlidePageRoute({
    required WidgetBuilder builder,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog = false,
  }) : super(
          transitionDuration: _kDuration,
          reverseTransitionDuration: _kDuration,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // PUSH:  animation 0 → 1  →  child slides in from right (1,0) → (0,0)
            // POP:   animation 1 → 0  →  child slides out to right  (0,0) → (1,0)
            final slideTween = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: _kCurve),
            );

            return SlideTransition(
              position: slideTween,
              child: child,
            );
          },
        );
}
