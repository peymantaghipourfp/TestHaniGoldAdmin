# AGENTS.md

Guidance for AI coding agents (Cursor, Claude, Codex, etc.) working in this repository. Keep this file authoritative and short; link out for details.

---

## 1. Project Overview

- **Name:** `hanigold_admin` (pubspec) - internal name in chats: "curserAi project".
- **Type:** Flutter application (Dart SDK `^3.6.0`) - private package (`publish_to: 'none'`).
- **Purpose:** Admin panel for the **Hanigold** gold-trading organization. Manages accounts, users, deposits/withdrawals, inventory, orders, transactions, wallets, chat, notifications, analytical reports, and role/permission management.
- **Targets:** Android, iOS, Web, Windows (primary, packaged via MSIX), macOS, Linux.
- **UI:** Right-to-left (RTL), Persian (`fa_IR`) primary locale, Shamsi calendar (`persian_datetime_picker`, `shamsi_date`).

---

## 2. Tech Stack

| Concern | Library |
| --- | --- |
| State management & DI | `get` (GetX) - controllers, bindings, routing |
| HTTP | `dio` (with custom `DioInterceptor`) |
| WebSocket | `web_socket_channel` via `SocketService` (singleton) |
| Local storage | `get_storage`, `flutter_secure_storage` |
| JSON | `json_annotation` + `json_serializable` + `build_runner` |
| Responsive layout | `responsive_framework` (MOBILE / TABLET / DESKTOP / 4K breakpoints) |
| Dialogs / loading | `flutter_smart_dialog`, `flutter_easyloading`, `fluttertoast` |
| Tables | `data_table_2`, `syncfusion_flutter_datagrid` |
| Charts | `syncfusion_flutter_charts` |
| Export | `excel`, `pdf`, `printing`, `file_saver` |
| Logging | `logger` (wrapped by `AppLogger`) |
| Lints | `flutter_lints` (see `analysis_options.yaml`) |
| Windows packaging | `msix` |

---

## 3. Directory Layout

```
lib/
  main.dart                  # App entry, MyApp, MaterialApp config, MSIX/tear-off args
  src/
    config/
      const/                 # AppColor, AppTextStyle, SocketService, ToastService, AudioService
      logger/                # AppLogger
      network/               # DioClient, DioInterceptor, ErrorException
      repository/            # All Dio-based repositories (one file per resource)
      routes/                # RoutePage (GetX route table) + bindings/*
      database/              # Local storage helpers
      tear_off_context.dart  # Multi-window "tear-off tab" CLI args
    domain/<feature>/        # One folder per business feature (see below)
      controller/            # GetX controllers (business logic, reactive state)
      model/                 # JSON-serializable models (*.model.dart + *.g.dart)
      view/                  # Top-level screens / pages
      widget/                # Feature-scoped widgets, dialogs, sub-components
    widget/                  # Cross-feature shared widgets (ZoomWrapper, etc.)
    utils/                   # Generic helpers
assets/                      # images/, svg/, sounds/, fonts/, icon/
test/                        # Flutter tests (currently sparse)
graphify-out/                # Knowledge graph (see Section 9)
```

### Feature domains (under `lib/src/domain/`)

`account`, `accountSalesGroup`, `analyticalReports`, `auth`, `balance`, `base`, `chat`, `creditHelper`, `deposit`, `home`, `inventory`, `laboratory`, `notification`, `order`, `product`, `remittance`, `role`, `splash`, `tools`, `transaction`, `transferWallet`, `users`, `wallet`, `withdraw`.

Each domain follows the **controller / model / view / widget** convention. Do **not** invent a different layout when adding features - match the existing pattern.

---

## 4. Architecture Conventions

### 4.1 GetX patterns

- **Controllers** extend `GetxController` (or `BaseController` from `domain/base/`). Use `.obs` reactive variables and `Rx<T>` types. Expose state as observables, not setters.
- **Bindings** live in `lib/src/config/routes/bindings/*.bindings.dart`. Register dependencies with `Get.lazyPut`/`Get.put`. Each route declared in `RoutePage` must have a matching `Binding`.
- **Navigation:** Use `Get.toNamed(...)` / `Get.offNamed(...)` with route constants from `RoutePage`. Do not push raw `MaterialPageRoute`.
- **Singletons:** `SocketService` and `HomeController` are `permanent: true` and registered in `main()`. Never re-register them.
- **Reactive UI:** Wrap UI in `Obx(() => ...)` rather than calling `update()` unless you have a specific reason.

### 4.2 Networking & data flow

- All HTTP calls go through `DioClient` (`lib/src/config/network/`) which adds auth headers and translates errors into `ErrorException`.
- One **Repository** per backend resource in `lib/src/config/repository/` (e.g. `account.repository.dart`, `deposit.repository.dart`). Controllers depend on repositories, never on `Dio` directly.
- Repositories throw `ErrorException` on failure; controllers catch and surface via `ToastService` / `EasyLoading` / dedicated error state.
- WebSocket payloads are decoded into `SocketChat*Model` classes under `lib/src/domain/chat/model/` and dispatched by `SocketService`.

### 4.3 Models (JSON)

- Models use `json_serializable`. Every `*.model.dart` has a generated `*.model.g.dart`.
- After editing any model annotation (`@JsonKey`, fields, `fromJson`/`toJson`), regenerate:
  ```
  dart run build_runner build --delete-conflicting-outputs
  ```
- **Never hand-edit `*.g.dart` files.** They are regenerated.

### 4.4 Theming & localization

- Colors: `AppColor` (`lib/src/config/const/app_color.dart`) - do not use hard-coded `Color(0x...)` in widgets.
- Text styles: `AppTextStyle` (`lib/src/config/const/app_text_style.dart`).
- Fonts: `IranSansR` (default), `IranSansB`, `Roboto`. Set in `pubspec.yaml`.
- App is RTL (`TextDirection.rtl`) with Persian locale; use `Directionality` only when intentionally switching.
- Dates entered by the user are Jalali (Shamsi) and converted via helpers like `convertJalaliToGregorianForApi` / `convertJalaliToGregorianCustomDate` before hitting the API.
- Numbers/currency: prefer `persian_number_utility` helpers (`.toWord()`, `.seRagham()`, etc.).

### 4.5 Multi-window / tear-off tabs

- Desktop builds support "tear-off" tabs launched as separate processes. `main.dart` parses `--route=`, `--tear-off`, `--tab-title=`, `--tab-icon=`. If you add new top-level features, ensure their routes work standalone.

---

## 5. Build, Run, Test

> All commands run from the project root.

| Task | Command |
| --- | --- |
| Install deps | `flutter pub get` |
| Run (Windows desktop) | `flutter run -d windows` |
| Run (web) | `flutter run -d chrome` |
| Run (Android) | `flutter run -d <device>` |
| Static analysis | `flutter analyze` |
| Format | `dart format .` |
| Generate JSON / mocks | `dart run build_runner build --delete-conflicting-outputs` |
| Watch generators | `dart run build_runner watch --delete-conflicting-outputs` |
| Unit / widget tests | `flutter test` |
| Build Android APK | `flutter build apk --release` |
| Build Windows MSIX | `flutter pub run msix:create` |
| App icons | `dart run flutter_launcher_icons` |

Lints: `package:flutter_lints/flutter.yaml` (see `analysis_options.yaml`). Do not weaken lint rules to silence warnings - fix the code.

---

## 6. Coding Standards

- **Language:** Dart with sound null safety. Avoid `!` and `as` casts unless the invariant is obvious; prefer `?.` and explicit type checks.
- **Naming:** `lower_snake_case` for files, `UpperCamelCase` for classes, `lowerCamelCase` for members. File suffixes are meaningful: `*.controller.dart`, `*.model.dart`, `*.view.dart`, `*.widget.dart`, `*.repository.dart`, `*.bindings.dart`.
- **Imports:** Prefer **package imports** (`package:hanigold_admin/...`) over deep relative imports for files outside the current folder. Order: `dart:`, `package:flutter/`, third-party, `package:hanigold_admin/`, then relative.
- **Logging:** Use `AppLogger.d/i/w/e`, not `print`. Never log secrets or full tokens.
- **Errors:** Throw `ErrorException` from repositories; catch and surface in controllers; never let raw `DioException` bubble into the UI.
- **Comments:** Only explain non-obvious intent, trade-offs, or constraints. Do not narrate code.
- **No new top-level state holders** outside `Get.put`. No global mutable singletons.

### When adding a new feature domain

1. Create `lib/src/domain/<feature>/{controller,model,view,widget}/`.
2. Add the repository under `lib/src/config/repository/<feature>.repository.dart`.
3. Add a binding under `lib/src/config/routes/bindings/<feature>.bindings.dart`.
4. Register the route in `lib/src/config/routes/route_page.dart`.
5. Reuse `AppColor`, `AppTextStyle`, `ToastService`, `AppLogger`.
6. Run `dart run build_runner build --delete-conflicting-outputs` if you added JSON models.
7. Run `flutter analyze` before considering the work done.

---

## 7. Things to Avoid

- Do not modify `*.g.dart`, `pubspec.lock`, files under `build/`, `.dart_tool/`, `android/app/`, `ios/Runner/`, `windows/runner/`, `macos/Runner/`, `linux/runner/` unless the task explicitly requires it.
- Do not bump dependency versions in `pubspec.yaml` opportunistically.
- Do not commit `certificate.pfx`, `certificate.cer`, passwords, or anything from `flutter_*.log`.
- Do not introduce a second state-management library (Provider/Riverpod/Bloc). The project standard is **GetX**.
- Do not add LTR-only widgets without verifying they behave under RTL.
- Do not hardcode API base URLs - use `lib/src/config/repository/url/base_url.dart`.

---

## 8. Security & Secrets

- Auth tokens live in `flutter_secure_storage` (`SecureCredentialsStorage`) and `get_storage` (`id`, `Authorization`).
- The Dio interceptor injects the Authorization header automatically; do not inline tokens.
- `certificate.pfx` / `certificate.cer` at the repo root are MSIX signing artifacts. Treat as sensitive.

---

## 9. Knowledge Graph (Graphify)

This project has a Graphify knowledge graph at `graphify-out/`.

- **Before answering architecture or codebase questions**, consult `graphify-out/GRAPH_REPORT.md` for god nodes, communities, and surprising connections.
- If `graphify-out/wiki/index.md` exists, navigate it instead of grepping raw files.
- **After modifying code files in this session**, run:
  ```
  graphify update .
  ```
  to keep the graph current (AST-only, no API cost).

Top "god nodes" today: `package:get/get.dart`, `package:flutter/material.dart`, `AppColor`, `AppTextStyle`, `ChatModel`. Treat changes to these as wide-blast-radius.

---

## 10. Project Agent Skills

| Skill | Path | When |
| --- | --- | --- |
| `senior-mobile` | `.cursor/skills/senior-mobile/SKILL.md` | Flutter/mobile features, performance, scaffolding, store submission |
| `ui-ux-pro-max` | `.cursor/skills/ui-ux-pro-max/SKILL.md` | UI/UX design, layout, visual polish |
| `design-auditor` | `.cursor/skills/design-auditor/SKILL.md` | UI/UX audit, AI-slop detection, WCAG contrast, design-token compliance |
| `ux-researcher-designer` | `.cursor/skills/ux-researcher-designer/SKILL.md` | Personas, journey maps, usability test plans, research synthesis |

Cursor rules: `.cursor/rules/senior-mobile.mdc` (Dart/mobile), `.cursor/rules/design-auditor.mdc` (UI audit / a11y), `.cursor/rules/ux-researcher-designer.mdc` (UX research). **AGENTS.md conventions override skill defaults** when they conflict (e.g. GetX, repository layout, `AppColor`).

---

## 11. Pull Request / Commit Etiquette

- Keep commits focused; one feature or fix per commit.
- Run `flutter analyze` and `dart format .` before committing.
- Never commit generated `*.g.dart` changes without the corresponding `*.model.dart` change.
- Do not commit unless the user explicitly asks. Cursor agents must not auto-commit.

## graphify

This project has a graphify knowledge graph at graphify-out/.

Rules:
- Before answering architecture or codebase questions, read graphify-out/GRAPH_REPORT.md for god nodes and community structure
- If graphify-out/wiki/index.md exists, navigate it instead of reading raw files
- For cross-module "how does X relate to Y" questions, prefer `graphify query "<question>"`, `graphify path "<A>" "<B>"`, or `graphify explain "<concept>"` over grep — these traverse the graph's EXTRACTED + INFERRED edges instead of scanning files
- After modifying code files in this session, run `graphify update .` to keep the graph current (AST-only, no API cost)

