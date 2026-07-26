### Task 7: Verification

- [ ] `flutter analyze` (project or at least inventory domain)
- [ ] `graphify update .` after code edits
- [ ] **Manual mobile-browser matrix** (Chrome Android + Safari iOS):
  1. Open edit receive â†’ pick camera â†’ thumbnail appears before submit
  2. Pick gallery (multi) â†’ all thumbnails appear
  3. Submit â†’ uploads succeed â†’ existing images row refreshes
  4. Repeat for edit payment
  5. Create flow temp-detail row: pick â†’ preview â†’ final submit uploads
  6. Induce failure (airplane mode mid-upload) â†’ selections remain, error shown, retry works

---
