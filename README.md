# Outfittr

An application for users to manage their wardrobes by creating outfits with their uploaded clothing items that can be saved, searched, edited, and deleted from the user's account. Items can be tagged for easier searching on the basis of the item's color, vibe, or season. Outfits can be named and given notes/description for the user to better personalize their wardrobe. Stretch goals include catalogue items, outfit recommendations, and item trimming via mobile.

---

## Architecture

Outfittr is a **MERN stack** application (MongoDB, Express, React, Node.js) extended with a Flutter mobile client. It has three layers:

```
┌─────────────────────┐     ┌─────────────────────┐
│   Frontend (React)  │     │   Mobile (Flutter)   │
│   Vite + TypeScript │     │   iOS / Android      │
└────────┬────────────┘     └──────────┬───────────┘
         │                             │
         │        REST API (HTTP)      │
         └──────────────┬──────────────┘
                        │
             ┌──────────▼──────────┐
             │   Backend (Node.js) │
             │   Express + JWT     │
             └──────────┬──────────┘
                        │
             ┌──────────▼──────────┐
             │   MongoDB (Atlas)   │
             │   OutfittrDB        │
             └─────────────────────┘
```

---

## Project Structure

### `/` — Backend (Express / Node.js — the "E" and "N" in MERN)
The REST API server that handles all business logic and database access.

- **`server.js`** — Express entry point. Connects to MongoDB and starts the server on port `5000`.
- **`api.js`** — Express route handlers for all API endpoints (`/api/login`, `/api/register`, `/api/additem`, `/api/searchitems`).
- **`createJWT.js`** — Utility for creating, refreshing, and validating JSON Web Tokens used for session auth.
- **`tokenStorage.ts`** — Client-side token storage helpers.

### `/frontend` — Web Frontend (React + TypeScript + Vite)
A single-page application for the browser.

- **`src/pages/`** — Top-level route pages:
  - `LoginPage.tsx` — User login
  - `RegisterPage.tsx` — New user registration
  - `OutfitManagerPage.tsx` — Main wardrobe/outfit management view
- **`src/components/`** — Reusable UI components (item display, login name display, page title, etc.)
- **`src/App.tsx`** — Router setup with React Router DOM.

### `/mobile` — Mobile App (Flutter / Dart)
A cross-platform mobile application targeting iOS and Android.

- **`lib/main.dart`** — App entry point and theme configuration.
- **`lib/pages/`** — App screens:
  - `login_page.dart` — Mobile login screen
  - `item_page.dart` — Item browsing/management screen
- Supports building for Android (`android/`), iOS (`ios/`), web (`web/`), Linux, macOS, and Windows targets.

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/login` | Authenticate a user, returns JWT |
| POST | `/api/register` | Register a new user, returns JWT |
| POST | `/api/additem` | Add a clothing item to the user's wardrobe |
| POST | `/api/searchitems` | Search wardrobe items by name (regex, case-insensitive) |

All authenticated endpoints require a `jwtToken` in the request body. Tokens are refreshed on every successful response.

---

## Prerequisites

- [Node.js](https://nodejs.org/) (v18+)
- [npm](https://www.npmjs.com/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (for mobile)
- A [MongoDB Atlas](https://www.mongodb.com/atlas) cluster (or local MongoDB instance)

---

## How to Run

### Backend

```bash
# From the root directory
npm install
npm start
```

The server runs on `http://localhost:5000`. Requires a `.env` file in the root with:

```env
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

The web app runs on `http://localhost:5173` by default (Vite).

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

Use `flutter devices` to list available targets (emulator, physical device, web, etc.).

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Backend | Node.js, Express (MERN), MongoDB, JWT |
| Frontend | React 19, TypeScript, Vite, React Router |
| Mobile | Flutter, Dart |
| Database | MongoDB (OutfittrDB) |
