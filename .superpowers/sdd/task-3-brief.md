### Task 3: Consume pending route after successful login

**Files:**
- Modify: `lib/src/domain/auth/controller/auth.controller.dart` (login success navigation ~line 128)
- Test: `test/pending_post_login_route_test.dart` (already covers `consumePendingPostLoginRoute`; no AuthController widget test required)

**Interfaces:**
- Consumes: `consumePendingPostLoginRoute()`, `RoutePage.knownRouteNames` (re-validate before navigate)
- Produces: post-login navigation to pending or `/home`

- [ ] **Step 1: Add imports to `auth.controller.dart`**

```dart
import 'package:hanigold_admin/src/config/pending_post_login_route.dart';
import 'package:hanigold_admin/src/config/routes/route_page.dart';
```

(Skip either import if already present.)

- [ ] **Step 2: Replace hard-coded home navigation**

Replace:

```dart
        registerChatControllerIfNeeded();
        Get.offNamed('/home');
```

with:

```dart
        registerChatControllerIfNeeded();
        final pending = consumePendingPostLoginRoute();
        final destination =
            isPendingPostLoginRouteAllowed(pending, RoutePage.knownRouteNames)
                ? pending!
                : '/home';
        Get.offNamed(destination);
```

Keep the surrounding order unchanged: write vault → FAB counts → `resetManualDisconnect` → `bootstrapSocketConnection` → `registerChatControllerIfNeeded` → navigate → remember-me persist.

- [ ] **Step 3: Analyze auth controller**

Run:

```bash
flutter analyze lib/src/domain/auth/controller/auth.controller.dart
```

Expected: No new issues.

- [ ] **Step 4: Commit**

```bash
git add lib/src/domain/auth/controller/auth.controller.dart
git commit -m "feat(auth): restore pending web route after successful login"
```

---
