# Auth Interceptor - Auto Token Refresh

## Overview
This interceptor automatically handles token refresh when the access token expires (401 error).

## How It Works

### 1. Normal Request Flow
```
User Request → Add Bearer Token → Send to Server → Success ✅
```

### 2. Token Expired Flow (401 Error)
```
User Request → 401 Error → Check Refresh Token
    ↓
Has Refresh Token?
    ├─ Yes → Call /auth/refresh endpoint
    │         ↓
    │    Success?
    │    ├─ Yes → Save new tokens → Retry original request ✅
    │    └─ No  → Clear auth → Redirect to login ❌
    │
    └─ No → Clear auth → Redirect to login ❌
```

### 3. Multiple Simultaneous Requests
```
Request 1 → 401 → Start refresh (lock)
Request 2 → 401 → Queue (wait for refresh)
Request 3 → 401 → Queue (wait for refresh)
    ↓
Refresh Success → Process all queued requests with new token ✅
```

## Features

✅ **Automatic Token Refresh**: No manual intervention needed
✅ **Request Queuing**: Handles multiple simultaneous 401 errors
✅ **Prevents Infinite Loops**: Won't try to refresh the refresh endpoint
✅ **Flexible Response Parsing**: Handles both `{access_token}` and `{data: {access_token}}`
✅ **Clean Logout**: Clears all auth data on refresh failure

## Backend Endpoint Expected

### Request
```json
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refresh_token": "your_refresh_token_here"
}
```

### Response (Option 1 - Direct)
```json
{
  "access_token": "new_access_token",
  "refresh_token": "new_refresh_token"
}
```

### Response (Option 2 - Nested in data)
```json
{
  "data": {
    "access_token": "new_access_token",
    "refresh_token": "new_refresh_token"
  }
}
```

## Error Handling

| Scenario | Action |
|----------|--------|
| No refresh token stored | Clear auth → Logout |
| Refresh endpoint returns 401 | Clear auth → Logout |
| Refresh endpoint fails | Clear auth → Logout |
| Network error during refresh | Clear auth → Logout |

## Testing

To test the refresh token flow:

1. Login to get tokens
2. Wait for access token to expire (or manually invalidate it)
3. Make any API request
4. The interceptor should automatically refresh and retry

## Notes

- The interceptor uses a separate Dio instance for refresh calls to avoid interceptor loops
- All queued requests are processed after successful refresh
- If refresh fails, all queued requests are rejected
- The `_isRefreshing` flag prevents multiple simultaneous refresh attempts
