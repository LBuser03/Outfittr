# Outfittr — Mobile (Flutter)

The mobile client for Outfittr. Built with Flutter/Dart, targeting iOS and Android (with additional support for web, desktop, and Linux builds). The app lets users log in and manage their clothing items from a mobile device.

---

## Tech Stack

- **Flutter** — UI framework (cross-platform)
- **Dart** (SDK `^3.11.4`) — Language
- **Material Design 3** — UI theme, seeded with the brand purple `#AA3BFF`

---

## Folder Structure

```
mobile/
├── lib/
│   ├── main.dart               # App entry point
│   └── pages/
│       ├── login_page.dart     # Login & sign-up screen
│       └── item_page.dart      # Item management screen
├── android/                    # Android-specific build config
├── ios/                        # iOS-specific build config
├── web/                        # Web target config
├── linux/ macos/ windows/      # Desktop target configs
├── test/
│   └── widget_test.dart        # Default widget smoke test
├── pubspec.yaml                # Dependencies & project metadata
└── analysis_options.yaml       # Dart linter config
```

---

## Pages

### `login_page.dart` — Login & Sign Up
A tabbed screen with two tabs: **Log In** and **Sign Up**.

- Uses a `TabController` to switch between the login and sign-up forms.
- **Login form**: email and password fields. On submit, credentials are validated and the user is navigated to `ItemPage` on success, or shown an error dialog on failure.
- **Sign-up form**: username, password, and confirm-password fields. Validates that passwords match before proceeding.
- **Note:** Authentication is currently hardcoded (`test@gmail.com` / `Anthony`). Backend API integration is a pending next step.
- Styled to mirror the web frontend — same `Outfittr` title typography and purple accent color.

### `item_page.dart` — Item Management
The main screen shown after a successful login.

- Displays a header bar showing **"Logged In As [username]"** and a **Log Out** button (pops back to login).
- **Search Items**: text field + Search button. Filters the local in-memory item list by a case-insensitive substring match and displays results.
- **Add Item**: text field + Add button. Appends a new item to the local in-memory list and shows a confirmation message.
- **Note:** Item storage is currently local/in-memory (a `List<String>`). Persistence via the backend API (`/api/additem`, `/api/searchitems`) is a pending next step.

---

## Entry Point

**`main.dart`** bootstraps the app:
- Sets the app title to `Outfittr`.
- Applies a `ThemeData` with a `ColorScheme` seeded from `#AA3BFF` (brand purple).
- Sets `LoginPage` as the initial route.

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.11.4`)
- For Android: Android Studio + an emulator or physical device
- For iOS: Xcode + a simulator or physical device (macOS only)

---

## How to Run

```bash
cd mobile

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run

# Run specifically in Chrome (web)
flutter run -d chrome

# List available devices
flutter devices
```

---

## Known Limitations / TODOs

- Login and sign-up use hardcoded credentials — needs wiring to `/api/login` and `/api/register`.
- Item list is in-memory only — needs wiring to `/api/additem` and `/api/searchitems`.
- JWT token handling for authenticated requests is not yet implemented.
