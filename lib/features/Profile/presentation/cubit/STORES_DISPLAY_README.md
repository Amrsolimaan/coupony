# Stores Display Cubit - Smart Caching Solution

## 📋 Overview

This cubit manages the display of seller stores in the profile page with intelligent caching to balance data freshness and performance.

## 🎯 Problem Solved

Previously, we relied on `user.stores` from the login response, which had several issues:
- ❌ **Stale Data**: Only updated on login
- ❌ **Incomplete**: Missing detailed store information (logo_url, categories, etc.)
- ❌ **Inconsistent**: Could differ from actual server state

## ✅ Solution

Use **GET /api/v1/stores** as the single source of truth with smart caching:

```dart
// Cache expires after 5 minutes
static const _cacheDuration = Duration(minutes: 5);
```

## 🔄 How It Works

### 1. First Load
```dart
context.read<StoresDisplayCubit>().loadStores();
```
- Fetches from API
- Caches result in memory
- Emits `StoresDisplayLoaded` state

### 2. Subsequent Loads (within 5 minutes)
```dart
context.read<StoresDisplayCubit>().loadStores();
```
- Returns cached data immediately
- No API call
- Fast response

### 3. After 5 Minutes
```dart
context.read<StoresDisplayCubit>().loadStores();
```
- Cache expired
- Fetches fresh data from API
- Updates cache

### 4. Manual Refresh
```dart
context.read<StoresDisplayCubit>().refreshStores();
```
- Forces API call
- Bypasses cache
- Updates with latest data

## 📊 States

| State | Description |
|-------|-------------|
| `StoresDisplayInitial` | Initial state, no data loaded |
| `StoresDisplayLoading` | Fetching from API |
| `StoresDisplayLoaded` | Data loaded successfully |
| `StoresDisplayError` | Failed to fetch data |

## 🎨 UI Integration

### Loading State
Shows a small loading indicator next to the section title.

### Loaded State
Displays stores in a horizontal scrollable list with:
- Store logo (circular)
- Store name
- Status badge (Active/Pending/Rejected)
- Refresh button

### Error State
Shows an error message with:
- Error icon
- Error description
- Retry button

## 🚀 Benefits

1. **Always Fresh**: Data is never more than 5 minutes old
2. **Fast**: Cached data loads instantly
3. **Reliable**: Single source of truth (API)
4. **User Control**: Manual refresh available
5. **Error Handling**: Graceful error states with retry

## 📝 Usage Example

```dart
// In main_profile.dart
BlocBuilder<StoresDisplayCubit, StoresDisplayState>(
  builder: (context, state) {
    if (state is StoresDisplayLoading) {
      return LoadingWidget();
    }
    
    if (state is StoresDisplayLoaded) {
      return StoresListWidget(stores: state.stores);
    }
    
    if (state is StoresDisplayError) {
      return ErrorWidget(message: state.message);
    }
    
    return SizedBox.shrink();
  },
)
```

## 🔧 Configuration

To change cache duration, modify:

```dart
// In stores_display_cubit.dart
static const _cacheDuration = Duration(minutes: 5); // Change this
```

## 🎯 Best Practices

1. **Don't call loadStores() repeatedly** - It's smart enough to use cache
2. **Use refreshStores() for pull-to-refresh** - Forces fresh data
3. **Clear cache on logout** - Call `clearCache()` when user logs out
4. **Handle all states** - Always handle Loading, Loaded, and Error states

## 📦 Dependencies

- `GetStoresUseCase`: Fetches stores from API
- `UserStoreModel`: Store data model
- `flutter_bloc`: State management

## 🔄 Data Flow

```
User Opens Profile
       ↓
StoresDisplayCubit.loadStores()
       ↓
Check Cache Valid?
   ↙         ↘
 YES         NO
   ↓          ↓
Return     Call API
Cache    (GET /api/v1/stores)
   ↓          ↓
   └──────────┘
       ↓
Emit StoresDisplayLoaded
       ↓
UI Updates
```

## 🎉 Result

A fast, reliable, and user-friendly stores display system that always shows accurate data while maintaining excellent performance!
