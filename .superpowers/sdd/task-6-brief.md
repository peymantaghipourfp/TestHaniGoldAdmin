### Task 6: Upload repository timeouts (minimal, optional but recommended)

**Files:**
- Modify: [upload.repository.dart](lib/src/config/repository/upload.repository.dart)

- [ ] Add to both `UploadRepository` and `UploadRepositoryDesktop` Dio setup:

```dart
uploadDio.options.connectTimeout = const Duration(seconds: 30);
uploadDio.options.sendTimeout = const Duration(seconds: 60);
uploadDio.options.receiveTimeout = const Duration(seconds: 30);
```

- [ ] Run analyzer

---
