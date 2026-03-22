# Cubit Message Key Usage Examples
## How to Display Localized Messages in UI

**Date**: 2026-03-21  
**Pattern**: Error Key Pattern with Extension Method

---

## Quick Start

### 1. Import Required Files

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/localization/message_key_extension.dart'; // ✅ Extension method
```

---

## Pattern 1: BlocListener for Snackbars

### Use Case: Show temporary messages (errors, success, info)

```dart
class LocationMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<PermissionFlowCubit, PermissionFlowState>(
      listener: (context, state) {
        // Check if there's a message to display
        if (state.messageKey != null) {
          final l10n = AppLocalizations.of(context)!;
          final message = l10n.getMessage(state.messageKey!); // ✅ Extension method
          
          // Determine color based on message type
          final backgroundColor = _getMessageColor(state.messageType);
          
          // Show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: backgroundColor,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Clear message after showing (optional)
          // context.read<PermissionFlowCubit>().clearMessage();
        }
      },
      child: Scaffold(
        // ... your UI
      ),
    );
  }
  
  Color _getMessageColor(MessageType? type) {
    switch (type) {
      case MessageType.error:
        return AppColors.error;
      case MessageType.success:
        return AppColors.success;
      case MessageType.info:
        return AppColors.info;
      default:
        return AppColors.grey800;
    }
  }
}
```

---

## Pattern 2: BlocBuilder for Inline Messages

### Use Case: Display persistent messages in UI (error banners, info boxes)

```dart
class LocationErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        
        return Scaffold(
          body: Column(
            children: [
              // Error Icon
              Icon(
                Icons.location_off,
                size: 80,
                color: AppColors.error,
              ),
              
              SizedBox(height: 24),
              
              // Error Message (Localized)
              if (state.messageKey != null)
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    l10n.getMessage(state.messageKey!), // ✅ Extension method
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              SizedBox(height: 32),
              
              // Action Buttons
              ElevatedButton(
                onPressed: () {
                  context.read<PermissionFlowCubit>().retryLocationPermission();
                },
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## Pattern 3: Combined Listener + Builder

### Use Case: Show snackbars AND update UI based on state

```dart
class OnboardingPreferencesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingFlowCubit, OnboardingFlowState>(
      // Listener for temporary messages (snackbars)
      listener: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        
        // Show success message
        if (state.successMessageKey != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.getMessage(state.successMessageKey!)),
              backgroundColor: AppColors.success,
            ),
          );
        }
        
        // Show error message
        if (state.errorMessageKey != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.getMessage(state.errorMessageKey!)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      
      // Builder for UI updates
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        
        return Scaffold(
          body: Column(
            children: [
              // Category Grid
              GridView.builder(
                // ... category items
              ),
              
              // Error Banner (if validation fails)
              if (state.errorMessageKey != null && !state.isStep1Valid)
                Container(
                  padding: EdgeInsets.all(12),
                  color: AppColors.errorLight,
                  child: Row(
                    children: [
                      Icon(Icons.error, color: AppColors.error),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.getMessage(state.errorMessageKey!),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Next Button
              ElevatedButton(
                onPressed: state.isStep1Valid
                    ? () => context.read<OnboardingFlowCubit>().completeCategorySelection()
                    : null,
                child: Text(l10n.next),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## Pattern 4: Custom Message Widget

### Use Case: Reusable message display component

```dart
// lib/core/widgets/message_banner.dart
class MessageBanner extends StatelessWidget {
  final String messageKey;
  final MessageType type;
  final VoidCallback? onDismiss;
  
  const MessageBanner({
    required this.messageKey,
    required this.type,
    this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = l10n.getMessage(messageKey);
    
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: _getTextColor(),
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: onDismiss,
              color: _getIconColor(),
            ),
        ],
      ),
    );
  }
  
  Color _getBackgroundColor() {
    switch (type) {
      case MessageType.error:
        return AppColors.errorLight;
      case MessageType.success:
        return AppColors.successLight;
      case MessageType.info:
        return AppColors.infoLight;
    }
  }
  
  Color _getBorderColor() {
    switch (type) {
      case MessageType.error:
        return AppColors.error;
      case MessageType.success:
        return AppColors.success;
      case MessageType.info:
        return AppColors.info;
    }
  }
  
  Color _getIconColor() => _getBorderColor();
  
  Color _getTextColor() => _getBorderColor();
  
  IconData _getIcon() {
    switch (type) {
      case MessageType.error:
        return Icons.error;
      case MessageType.success:
        return Icons.check_circle;
      case MessageType.info:
        return Icons.info;
    }
  }
}

// Usage:
BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
  builder: (context, state) {
    return Column(
      children: [
        if (state.messageKey != null)
          MessageBanner(
            messageKey: state.messageKey!,
            type: state.messageType ?? MessageType.info,
            onDismiss: () {
              context.read<PermissionFlowCubit>().clearMessage();
            },
          ),
        // ... rest of UI
      ],
    );
  },
)
```

---

## Pattern 5: Dialog with Localized Message

### Use Case: Show error/success in a dialog

```dart
void _showMessageDialog(BuildContext context, String messageKey, MessageType type) {
  final l10n = AppLocalizations.of(context)!;
  final message = l10n.getMessage(messageKey);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(
            type == MessageType.error ? Icons.error : Icons.check_circle,
            color: type == MessageType.error ? AppColors.error : AppColors.success,
          ),
          SizedBox(width: 8),
          Text(
            type == MessageType.error ? l10n.error : l10n.success,
            style: AppTextStyles.h4,
          ),
        ],
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.ok),
        ),
      ],
    ),
  );
}

// Usage in BlocListener:
BlocListener<PermissionFlowCubit, PermissionFlowState>(
  listener: (context, state) {
    if (state.messageKey != null) {
      _showMessageDialog(
        context,
        state.messageKey!,
        state.messageType ?? MessageType.info,
      );
    }
  },
  child: YourWidget(),
)
```

---

## Pattern 6: Loading with Message

### Use Case: Show loading indicator with localized message

```dart
class LoadingOverlay extends StatelessWidget {
  final String? messageKey;
  
  const LoadingOverlay({this.messageKey});
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                if (messageKey != null) ...[
                  SizedBox(height: 16),
                  Text(
                    l10n.getMessage(messageKey!),
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Usage:
BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
  builder: (context, state) {
    return Stack(
      children: [
        // Main content
        YourMainWidget(),
        
        // Loading overlay
        if (state.isRequestingLocation)
          LoadingOverlay(
            messageKey: 'permissions_location_checking',
          ),
      ],
    );
  },
)
```

---

## Best Practices

### 1. Always Use Extension Method ✅

```dart
// ✅ GOOD
final message = l10n.getMessage(state.messageKey!);

// ❌ BAD - Don't access properties directly
final message = l10n.error_location_position_failed;
```

### 2. Check for Null Before Using ✅

```dart
// ✅ GOOD
if (state.messageKey != null) {
  final message = l10n.getMessage(state.messageKey!);
  // ... show message
}

// ❌ BAD - Will crash if messageKey is null
final message = l10n.getMessage(state.messageKey!);
```

### 3. Clear Messages After Showing ✅

```dart
// ✅ GOOD - Clear message after showing snackbar
BlocListener<PermissionFlowCubit, PermissionFlowState>(
  listener: (context, state) {
    if (state.messageKey != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.getMessage(state.messageKey!))),
      );
      
      // Clear message so it doesn't show again
      context.read<PermissionFlowCubit>().clearMessage();
    }
  },
)
```

### 4. Use Appropriate Message Type ✅

```dart
// ✅ GOOD - Use correct type for styling
if (state.messageType == MessageType.error) {
  // Show red error banner
} else if (state.messageType == MessageType.success) {
  // Show green success banner
}

// ❌ BAD - Assuming all messages are errors
// Always check messageType
```

### 5. Provide Fallback for Unknown Keys ✅

```dart
// ✅ GOOD - Extension method already provides fallback
String getMessage(String key) {
  switch (key) {
    case 'error_location_position_failed':
      return error_location_position_failed;
    // ... other cases
    default:
      return unexpectedError; // ✅ Fallback
  }
}
```

---

## Testing

### Unit Test Example:

```dart
test('should emit correct message key on error', () async {
  // Arrange
  when(() => mockRepository.getCurrentPosition())
      .thenAnswer((_) async => Left(LocationFailure()));
  
  // Act
  await cubit.requestLocationPermission();
  
  // Assert
  expect(
    cubit.state.messageKey,
    equals('error_location_position_failed'),
  );
  expect(
    cubit.state.messageType,
    equals(MessageType.error),
  );
});
```

### Widget Test Example:

```dart
testWidgets('should display localized error message', (tester) async {
  // Arrange
  final cubit = MockPermissionFlowCubit();
  when(() => cubit.state).thenReturn(
    PermissionFlowState(
      messageKey: 'error_location_position_failed',
      messageType: MessageType.error,
    ),
  );
  
  // Act
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider.value(
        value: cubit,
        child: LocationErrorPage(),
      ),
    ),
  );
  
  // Assert
  expect(
    find.text('Could not determine your current location. Make sure GPS is enabled'),
    findsOneWidget,
  );
});
```

---

## Common Pitfalls to Avoid

### ❌ Pitfall 1: Hardcoding Messages in UI

```dart
// ❌ BAD
Text('تعذر تحديد موقعك الحالي')

// ✅ GOOD
Text(l10n.getMessage(state.messageKey!))
```

### ❌ Pitfall 2: Not Handling Null Message Keys

```dart
// ❌ BAD - Will crash
Text(l10n.getMessage(state.messageKey!))

// ✅ GOOD
if (state.messageKey != null) {
  Text(l10n.getMessage(state.messageKey!))
}
```

### ❌ Pitfall 3: Showing Messages Multiple Times

```dart
// ❌ BAD - Snackbar shows on every rebuild
BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
  builder: (context, state) {
    if (state.messageKey != null) {
      ScaffoldMessenger.of(context).showSnackBar(...); // ❌ Wrong place
    }
    return YourWidget();
  },
)

// ✅ GOOD - Use BlocListener
BlocListener<PermissionFlowCubit, PermissionFlowState>(
  listener: (context, state) {
    if (state.messageKey != null) {
      ScaffoldMessenger.of(context).showSnackBar(...); // ✅ Correct
    }
  },
  child: YourWidget(),
)
```

---

## Conclusion

✅ Use `l10n.getMessage(messageKey)` extension method  
✅ Check for null before accessing message keys  
✅ Use BlocListener for temporary messages (snackbars)  
✅ Use BlocBuilder for persistent messages (banners)  
✅ Clear messages after showing to avoid duplicates  
✅ Use appropriate message types for styling  
✅ Test with both languages to ensure translations work  

This pattern ensures full localization support while keeping the code clean and maintainable.
