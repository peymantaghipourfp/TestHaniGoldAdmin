# Whole-branch Review Package — Defer Chat API Loads
Plan: docs/superpowers/plans/2026-07-11-defer-chat-api-loads.md
Base: pre-change working tree (no git)
Head: post Tasks 1–2

## Goal
Stop Account/get and Chat/getChatAccount from firing at login; load only when chat UI needs them.

## Commits
None (workspace has no git repository).

## Files changed
1. lib/src/domain/chat/controller/chat.controller.dart
2. lib/src/domain/chat/widget/chat_dialog.widget.dart
3. lib/src/domain/chat/widget/dialogs/add_user_dialog.dart
4. test/chat_controller_lazy_load_test.dart (new)
5. docs/superpowers/plans/2026-07-11-defer-chat-api-loads.md (plan copy)

## Combined change summary

### chat.controller.dart
- Added @visibleForTesting shouldFetchChatAccounts / shouldFetchAccountList
- onInit: removed loadAccountList() and loadChatAccountList(refresh: true); kept socket + listeners
- Added ensureChatAccountsLoaded() / ensureAccountListLoaded() using those predicates

### chat_dialog.widget.dart
- import dart:async
- initState: unawaited(_controller.ensureChatAccountsLoaded()) after Get.find

### add_user_dialog.dart
- import dart:async
- showAddUserDialog: unawaited(controller.ensureAccountListLoaded()) at start

### test/chat_controller_lazy_load_test.dart
- Predicate unit tests (2 tests, both passing)

## Verification evidence
- flutter test test/chat_controller_lazy_load_test.dart → 2/2 pass
- flutter analyze on 3 chat files → 0 new errors; 1 pre-existing info use_build_context_synchronously at chat.controller.dart:281
- graphify update . run after changes

## Minor findings carried from task reviews (for triage)
- TOCTOU: ensure* checks isLoading before load* sets the flag; concurrent ensure* could double-fetch (not plan-required)
- Manual E2E checklist not executed in-session (login logs / open chat / add user / reopen)
- ensure* methods themselves not unit-tested (only predicates)

## Global constraints
- Do not change repository endpoints, payloads, or Account/get ToIndex: 100000
- Do not remove registerChatControllerIfNeeded() from login / bootstrap
- Match existing GetX / RTL / Persian UI patterns; no new state-management libs
- Minimal diff only — no chat UI redesign
