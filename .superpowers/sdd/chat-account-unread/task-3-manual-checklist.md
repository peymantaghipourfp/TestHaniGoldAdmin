# Task 3 — Manual validation checklist

Dual-window / cross-tab `ChatAccountItem` unread badge sync.

## Prerequisites

- Two app instances (tear-off tabs on Windows **or** two browser windows on web)
- Same admin account logged in on both
- Chat account list visible in both windows

## Steps

| # | Scenario | Expected | Result |
|---|----------|----------|--------|
| 1 | Send/receive a message so an account has unread | Both windows show unread badge on `ChatAccountItem` without opening that chat | **Pending (human)** |
| 2 | Mark read in window A (open chat, scroll/read) | Window B's `ChatAccountItem` badge clears without opening that chat in B | **Pending (human)** |
| 3 | Self-seen with incomplete payload (if reproducible) | Badge eventually converges via debounced reconcile (~300ms) | **Pending (human)** |
| 4 | Empty/malformed `chat.seen` payload | No white screen; existing badges unchanged | **Pending (human)** |

## Notes

- Reconcile is debounced 300ms; allow a short pause before judging step 3.
- Automated unit tests cover schedule hooks and fail-safe badge rules; this checklist requires a human on dual windows.
