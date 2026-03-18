# 🔐 Permission Feature - Clean Architecture

## 📁 Structure

```
lib/features/permissions/presentation/
│
├── constants/
│   └── permission_constants.dart        # Dimensions & spacing constants
│
├── widgets/
│   ├── atoms/                           # Smallest reusable components
│   │   ├── permission_icon.dart
│   │   ├── permission_primary_button.dart
│   │   └── permission_text_button.dart
│   │
│   ├── molecules/                       # Combination of atoms
│   │   ├── permission_header.dart
│   │   └── permission_action_buttons.dart
│   │
│   ├── organisms/                       # Complex components
│   │   └── permission_content_card.dart
│   │
│   └── widgets.dart                     # Barrel file
│
└── pages/                               # Complete screens
    ├── permission_splash_page.dart
    ├── location_intro_page.dart
    ├── location_map_page.dart
    ├── location_error_page.dart
    ├── notification_intro_page.dart
    ├── notification_error_page.dart
    ├── permission_loading_page.dart
    └── pages.dart                       # Barrel file
```

## 🎨 Design Principles

### ✅ Using Existing Theme
- **Colors**: Uses `AppColors` from core theme (primary, textPrimary, etc.)
- **TextStyles**: Uses `AppTextStyles` directly (h3, bodyMedium, button)
- **No duplication**: All styling comes from the existing theme system

### ✅ Atomic Design Pattern
1. **Atoms**: Basic building blocks (icon, buttons)
2. **Molecules**: Combination of atoms (header, action buttons)
3. **Organisms**: Complex components (content card)
4. **Pages**: Complete screens using organisms

### ✅ Responsive Design
- All dimensions use `ScreenUtil` (.w, .h, .r, .sp)
- Design base: 375x812 (iPhone X)
- Auto-scales for all screen sizes

### ✅ Clean Code
- Single Responsibility Principle
- DRY (Don't Repeat Yourself)
- Reusable components
- Easy to maintain

## 🔗 Integration with Cubit

All pages include commented examples showing how to connect with `PermissionFlowCubit`.

### Example:
```dart
// Replace:
BlocBuilder(...)

// With:
BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
  builder: (context, state) {
    return PermissionContentCard(
      isPrimaryLoading: state.isRequestingLocation,
      onPrimaryPressed: () => context.read<PermissionFlowCubit>()
          .requestLocationPermission(),
      // ...
    );
  },
)
```

## 📝 TODO

1. ✅ Add actual asset images to `assets/icons/`
2. ✅ Uncomment Cubit integration in pages
3. ✅ Add proper routing in `AppRouter`
4. ✅ Test navigation flow
5. ✅ Add localization strings

## 🚀 Usage

### Import widgets:
```dart
import 'widgets/widgets.dart';
```

### Import pages:
```dart
import 'pages/pages.dart';
```

### Use components:
```dart
PermissionContentCard(
  iconAssetPath: 'assets/icons/location.png',
  title: 'الموقع',
  subtitle: 'السماح للتطبيق...',
  primaryButtonText: 'سماح',
  onPrimaryPressed: () => ...,
  skipButtonText: 'تخطي الآن',
  onSkipPressed: () => ...,
)
```

## ✨ Features

- 🎨 Pixel-perfect design matching Figma
- 📱 Fully responsive
- 🌐 RTL support (Arabic)
- ♿ Accessible
- ⚡ Performance optimized
- 🧪 Easy to test
- 📦 Reusable components
- 🔧 Easy to maintain

---

**Created with ❤️ following Flutter best practices**
