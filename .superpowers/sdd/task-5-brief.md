### Task 5: Verification + graphify

**Files:** none new (verification only)

- [ ] **Step 1: Run focused + related session tests**

Run:

```bash
flutter test test/pending_post_login_route_test.dart test/dio_interceptor_session_header_test.dart test/session_invalidation_test.dart test/secure_session_storage_test.dart
```

Expected: All PASS.

- [ ] **Step 2: Analyze changed production files**

Run:

```bash
flutter analyze lib/src/config/pending_post_login_route.dart lib/src/config/session_bootstrap.dart lib/src/config/routes/route_page.dart lib/src/domain/auth/controller/auth.controller.dart lib/src/config/network/dio_Interceptor.dart
```

Expected: No issues in these files.

- [ ] **Step 3: Manual web checklist (engineer)**

1. Login → open `#/listUserInfoTransaction` → F5 → login screen (no 401 spam from that page before login).
2. Login again → lands on list; Dio has `Authorization`, no `x-session-id` header; socket identifies with vault `sessionId`.
3. Two tabs → close one → other keeps session.
4. Close last tab → reopen → login required.

- [ ] **Step 4: Update knowledge graph**

Run from repo root:

```bash
graphify update .
```

- [ ] **Step 5: Commit graphify outputs only if they changed and are normally tracked**

```bash
git add graphify-out/GRAPH_REPORT.md graphify-out/graph.json graphify-out/manifest.json
git status
```

If those files changed:

```bash
git commit -m "chore: refresh graphify after session boot and Dio header changes"
```

If unchanged, skip commit.

---
