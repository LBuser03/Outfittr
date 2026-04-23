# Outfittr Mobile

Flutter mobile client for Outfittr — a digital wardrobe manager for creating and organizing outfits. Connects to the shared Express/MongoDB backend via REST API with JWT authentication.

---

## 🏗️ Architecture

```
lib/
├── main.dart                     # App entry point & auth gate
├── config/
│   └── api_config.dart           # Backend base URL
├── models/
│   ├── item.dart                 # Clothing item model
│   └── outfit.dart               # Outfit model (embeds items)
├── services/
│   ├── auth_service.dart         # Login, register, JWT management
│   ├── item_service.dart         # Item CRUD & search
│   └── outfit_service.dart       # Outfit CRUD & search
├── screens/
│   ├── login_screen.dart         # Login form
│   ├── register_screen.dart      # Registration form
│   └── outfit_manager_screen.dart# Main home (3-tab UI)
├── widgets/
│   ├── bubble_title.dart         # Graffiti-style animated titles
│   ├── graffiti_background.dart  # Dark textured full-screen backdrop
│   ├── graffiti_button.dart      # Gradient pill buttons (4 variants)
│   ├── graffiti_card.dart        # Translucent backdrop-blur card
│   ├── graffiti_text_field.dart  # Dark-themed text inputs
│   ├── items_tab.dart            # Wardrobe grid + item form
│   ├── model_preview_card.dart   # Stick figure with clothing layers
│   ├── outfit_preview_tab.dart   # Outfit builder with slot picker
│   ├── outfits_tab.dart          # Saved outfits list
│   └── slot_tile.dart            # Individual clothing slot tile
└── theme/
    └── app_theme.dart            # Colors, text styles, MaterialApp theme
```

---

## 📱 Screens

### `LoginScreen`
Email + password form. Detects unverified accounts and surfaces a "Resend verification email" button. Routes to `OutfitManagerScreen` on success.

### `RegisterScreen`
New account creation with client-side password validation (requires uppercase, lowercase, digit, and special character). Redirects back to login after success — does not auto-login.

### `OutfitManagerScreen`
Main home screen with a 3-tab bottom nav:

| Tab | Name | Purpose |
|-----|------|---------|
| 0 | Preview | Outfit builder with stick figure model |
| 1 | Items | Wardrobe grid — browse, add, edit, delete |
| 2 | Outfits | Saved outfits list — browse, edit, delete |

---

## ⚙️ Services

### `AuthService`
Handles JWT lifecycle via `SharedPreferences`.

| Method | Description |
|--------|-------------|
| `login(email, password)` | POST `/api/login`, persists token |
| `register(email, password)` | POST `/api/register` |
| `logout()` | Removes stored JWT |
| `isLoggedIn()` | Checks token existence and expiry |
| `currentToken()` | Returns stored JWT string |
| `currentUserId()` | Decodes JWT to extract `userId` |
| `resendVerification(email)` | POST `/api/resend-verification` |

### `ItemService`
Full CRUD for wardrobe items. Uses multipart form data for image uploads.

| Method | Description |
|--------|-------------|
| `searchItems(query)` | POST `/api/searchitems` |
| `addItem(...)` | POST `/api/additem` — supports image bytes |
| `editItem(...)` | POST `/api/edititem` — omit image to keep existing |
| `deleteItem(itemId)` | POST `/api/deleteitem` |

### `OutfitService`
Full CRUD for outfits. Item IDs sent as a JSON array string.

| Method | Description |
|--------|-------------|
| `listOutfits()` | POST `/api/searchoutfits` (empty query = all) |
| `addOutfit(...)` | POST `/api/addoutfit` |
| `editOutfit(...)` | POST `/api/editoutfit` |
| `deleteOutfit(outfitId)` | POST `/api/deleteoutfit` |

Both services automatically detect expired JWT responses and trigger logout.

---

## 🧩 Widgets

| Widget | Description |
|--------|-------------|
| `BubbleTitle` | Per-character rotated graffiti titles with pink/aqua drop shadows |
| `GraffitiBackground` | Dark base + texture overlay + radial pink/aqua gradients |
| `GraffitiButton` | Gradient pill buttons — variants: `primary`, `aqua`, `pink`, `ghost` |
| `GraffitiCard` | Translucent panel with 8px backdrop blur, used for auth forms |
| `GraffitiTextField` | Dark-themed inputs — standard border or pink underline style |
| `ItemsTab` | Wardrobe 2-column grid with search, inline add/edit form, image picker |
| `ModelPreviewCard` | Stick figure (`assets/images/figure.png`) with network-image clothing layers |
| `OutfitPreviewTab` | Outfit name input + model preview + 2×2 slot grid + save button |
| `OutfitsTab` | Searchable outfit list with emoji item pips (🧢👕👖👟) |
| `SlotTile` | Single clothing slot — empty (dashed) or filled (gradient + thumbnail) |

---

## 🎨 Theme

Defined in `lib/theme/app_theme.dart`.

| Token | Value | Usage |
|-------|-------|-------|
| `bgDark` | `#120B08` | App background |
| `textPrimary` | `#F3E8D0` | Body text |
| `textBright` | `#FFF8EB` | Headings |
| `accentCoral` | `#FF5A36` | Primary CTA |
| `accentAqua` | `#56F0D4` | Secondary accent |
| `accentGold` | `#FFD447` | Highlight |
| `accentPink` | `#FF2D7A` | Logos, borders |

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `http` | ^1.2.0 | REST API calls |
| `shared_preferences` | ^2.2.0 | JWT persistence |
| `jwt_decoder` | ^2.0.1 | Decode JWT payload (`userId`, expiry) |
| `image_picker` | ^1.0.0 | Gallery/camera image selection |

---

## 🚀 Getting Started

```bash
flutter pub get
flutter run
```

> Make sure the backend is running and `lib/config/api_config.dart` points to the correct host (e.g. `http://10.0.2.2:5000` for Android emulator, `http://localhost:5000` for iOS simulator).

---

## 🔐 Auth Flow

1. App starts → `_AuthGate` checks `SharedPreferences` for a valid JWT
2. Valid token → `OutfitManagerScreen`
3. No/expired token → `LoginScreen`
4. On logout → token cleared, back to `LoginScreen`
