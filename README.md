<div align="center">

![Outfittr Banner](frontend/public/banner.png)

# Outfittr

**A digital wardrobe manager for creating and organizing outfits.**

</div>

---

## ✨ Features

- **Wardrobe Catalog** — Add, edit, and delete clothing items with photos, types, and tags
- **Outfit Builder** — Combine items into outfits using visual slots (Hat, Shirt, Pants, Shoes, Jacket, Accessory)
- **Search & Filter** — Search items and outfits with regex-powered filtering
- **Account System** — Full auth flow: register, email verification, login, forgot/reset password
- **Cross-platform** — Available as a web app and Flutter mobile app

---

## 🏗️ Architecture

```
Outfittr/
├── backend/           # Express API (root-level files)
├── frontend/          # React web client
│   ├── public/
│   └── src/
│       ├── components/
│       └── pages/
└── mobile/            # Flutter mobile app
    └── lib/
        ├── models/
        ├── screens/
        ├── services/
        └── widgets/
```

The backend is the source of truth. Both the web frontend and Flutter mobile app consume the same REST API and share JWT-based authentication.

---

## 🛠️ Tech Stack

| Layer    | Technology |
|----------|-----------|
| Backend  | Node.js, Express.js, MongoDB |
| Auth     | JWT, bcryptjs |
| Storage  | Cloudinary (images), Multer (upload handling) |
| Email    | Nodemailer, Resend |
| Frontend | React 19, TypeScript, Vite, React Router |
| Mobile   | Flutter, Dart, SharedPreferences |

---

## 📡 API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/register` | Create a new account |
| GET | `/api/verify` | Verify email address |
| POST | `/api/login` | Login and receive JWT |
| GET | `/api/me` | Get current session user |
| POST | `/api/forgot-password` | Initiate password reset |
| POST | `/api/reset-password` | Complete password reset |

### Items
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/additem` | Add a clothing item |
| POST | `/api/edititem` | Update an existing item |
| POST | `/api/deleteitem` | Delete an item |
| POST | `/api/searchitems` | Search and filter items |

### Outfits
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/addoutfit` | Create an outfit |
| POST | `/api/editoutfit` | Update an outfit |
| POST | `/api/deleteoutfit` | Delete an outfit |
| POST | `/api/searchoutfits` | Search and filter outfits |

---

## 🚀 Getting Started

### Backend
```bash
npm install
npm run dev
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

### Mobile
```bash
cd mobile
flutter pub get
flutter run
```

> The backend runs on `localhost:5000` by default. Make sure your `.env` is configured with MongoDB URI, JWT secret, and Cloudinary credentials before starting.
