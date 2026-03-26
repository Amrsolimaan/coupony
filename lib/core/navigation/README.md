# App Navigation & Page Transitions 🎬

Custom page transition system with **centralized control** from a single file.

## Features ✨

- 🎯 **One File Control**: Change transition for entire app from `app_transitions.dart`
- 📁 **Modular Design**: Each transition in its own folder
- 🎬 **Fade Scale Slide**: Current smooth, premium transition
- 🚀 **High Performance**: Optimized for 60fps
- 📱 **GoRouter Compatible**: Works seamlessly with go_router
- 🎨 **Easy to Extend**: Add new transitions without touching existing code

## Architecture 🏗️

```
lib/core/navigation/
├── app_transitions.dart              # ⭐ CENTRAL CONTROL - Change here!
├── app_page_transition.dart          # GoRouter integration
├── app_page_route.dart               # Navigator.push support
└── transitions/                      # Transition implementations
    ├── fade_scale_slide/             # Current transition
    │   ├── fade_scale_slide_config.dart
    │   └── fade_scale_slide_transition.dart
    └── sharp_reveal/                 # Future transition (example)
        ├── sharp_reveal_config.dart
        └── sharp_reveal_transition.dart
```

## Central Control 🎛️

**The most important file**: `app_transitions.dart`

To change the transition for the **entire app**, just update one line:

```dart
// In app_transitions.dart
static TransitionBuilder get currentTransition => FadeScaleSlideTransition.builder;

// Want a different transition? Just change this:
static TransitionBuilder get currentTransition => SharpRevealTransition.builder;
```

That's it! All pages automatically use the new transition. No need to update routes.

## Quick Start 🚀

### Option 1: With GoRouter (Recommended)

```dart
GoRoute(
  path: '/login',
  pageBuilder: (context, state) => AppPageTransition.build(
    context: context,
    state: state,
    child: LoginScreen(),
  ),
),
```

### Option 2: With Navigator

```dart
Navigator.of(context).push(
  AppPageRoute(
    builder: (context) => LoginScreen(),
  ),
);
```

### Option 3: No Transition (Instant)

```dart
GoRoute(
  path: '/splash',
  pageBuilder: (context, state) => AppPageTransition.buildNoTransition(
    context: context,
    state: state,
    child: SplashScreen(),
  ),
),
```

## Current Transition: Fade Scale Slide 🎭

A smooth, premium transition perfect for e-commerce apps like Coupony.

### Incoming Page (New Page)
1. **Fade**: 0% → 100% opacity
2. **Scale**: 92% → 100% size
3. **Slide**: 30px from bottom → 0px
4. **Duration**: 280ms
5. **Curve**: easeOutCubic

### Outgoing Page (Previous Page)
1. **Fade**: 100% → 0% opacity
2. **Scale**: 100% → 97% size
3. **Duration**: 280ms
4. **Curve**: easeInCubic

## Customization 🎨

All settings for the current transition are in: `transitions/fade_scale_slide/fade_scale_slide_config.dart`

### Change Duration

```dart
static const Duration duration = Duration(milliseconds: 280); // Change this
```

### Change Scale Effect

```dart
static const double incomingPageInitialScale = 0.92; // Start smaller
static const double outgoingPageFinalScale = 0.97;   // End smaller
```

### Change Slide Distance

```dart
static const double incomingPageVerticalOffset = 30.0; // Pixels from bottom
```

### Change Animation Curve

```dart
static const Curve incomingPageCurve = Curves.easeOutCubic; // Smooth curve
```

## Adding a New Transition 🆕

1. **Create folder**: `transitions/my_transition/`
2. **Create config**: `my_transition_config.dart`
3. **Create transition**: `my_transition_transition.dart`
4. **Add static builder**:

```dart
class MyTransition extends StatelessWidget {
  // ... widget code ...
  
  static Widget builder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return MyTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}
```

5. **Import in app_transitions.dart**:

```dart
import 'transitions/my_transition/my_transition_transition.dart';
```

6. **Update currentTransition**:

```dart
static TransitionBuilder get currentTransition => MyTransition.builder;
```

Done! All pages now use your new transition.

## Benefits ✅

- ✅ Change transition globally from **one file**
- ✅ Modular - each transition in its own folder
- ✅ Easy to add new transitions
- ✅ Clean Architecture compliant
- ✅ Works with both GoRouter and Navigator
- ✅ Type-safe with `TransitionBuilder` typedef
- ✅ No need to update routes when changing transitions

## Performance Tips ⚡

- ✅ Uses `allowSnapshotting: true` for better performance
- ✅ Optimized animation curves
- ✅ Short duration (280ms) for snappy feel
- ✅ No heavy computations during animation

## Troubleshooting 🔧

### Transition feels slow?
→ Reduce `duration` in the config file

### Want more bounce?
→ Change `incomingPageCurve` to `Curves.elasticOut`

### Want less slide?
→ Reduce `incomingPageVerticalOffset` to 15.0 or 20.0

### Want instant transitions?
→ Use `AppPageTransition.buildNoTransition()`

### Want to switch transition type?
→ Update `currentTransition` in `app_transitions.dart`

## Migration Guide 🔄

### Before (Default GoRouter)

```dart
GoRoute(
  path: '/login',
  builder: (context, state) => LoginScreen(),
),
```

### After (With Custom Transition)

```dart
GoRoute(
  path: '/login',
  pageBuilder: (context, state) => AppPageTransition.build(
    context: context,
    state: state,
    child: LoginScreen(),
  ),
),
```

## Technical Details 🔬

- Uses `CustomTransitionPage` from go_router
- Implements `PageRoute` for Navigator compatibility
- Stack-based animation (outgoing + incoming)
- Respects RTL/LTR automatically
- No external dependencies (pure Flutter)
- Type-safe transition builder pattern

## Files 📁

- `app_transitions.dart` - **Central control** (change transition here)
- `app_page_transition.dart` - GoRouter support
- `app_page_route.dart` - Navigator.push support
- `transitions/fade_scale_slide/fade_scale_slide_config.dart` - Current transition settings
- `transitions/fade_scale_slide/fade_scale_slide_transition.dart` - Current transition logic
