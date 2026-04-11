# Outfittr — Backend (Node.js / Express)

The REST API server for Outfittr. Built with Node.js and Express, it handles all authentication, business logic, and database access. Connects to a MongoDB Atlas cluster and communicates with both the web frontend and mobile client over HTTP.

---

## Tech Stack

- **Node.js** — Runtime
- **Express** `^4.22.1` — HTTP server and routing
- **MongoDB** `^5.9.2` — Database driver (Atlas)
- **jsonwebtoken** `^9.0.3` — JWT creation and verification
- **dotenv** `^17.3.1` — Environment variable loading
- **cors** `^2.8.6` — Cross-origin request handling
- **nodemon** — Dev server with auto-restart on file changes

---

## Folder Structure

```
backend/
├── server.js       # Entry point — starts Express and connects to MongoDB
├── api.js          # All route/endpoint definitions
├── createJWT.js    # JWT utility (create, verify, refresh)
├── package.json    # Dependencies and npm scripts
├── .env            # Environment variables (not committed)
└── .gitignore      # Ignores .env and node_modules
```

---

## Files

### `server.js` — Entry Point
- Loads environment variables via `dotenv`.
- Initialises Express with `cors` and `express.json()` middleware.
- Connects to MongoDB Atlas once on startup using `MONGODB_URI`.
- Delegates all route registration to `api.js`.
- Listens on port `5000`.

### `api.js` — Route Handlers
Exports a `setApp(app, client)` function that registers all API endpoints.

| Method | Endpoint | Incoming | Outgoing |
|--------|----------|----------|----------|
| POST | `/api/login` | `login`, `password` | `accessToken`, `error` |
| POST | `/api/register` | `login`, `password`, `firstName`, `lastName` | `accessToken`, `error` |
| POST | `/api/additem` | `userId`, `item`, `jwtToken` | `jwtToken`, `error` |
| POST | `/api/searchitems` | `userId`, `search`, `jwtToken` | `results[]`, `jwtToken`, `error` |

All authenticated endpoints (`additem`, `searchitems`) validate the JWT before processing and return a refreshed token on success.

### `createJWT.js` — JWT Utilities
- **`createToken(firstName, lastName, id)`** — Signs a new JWT with a 30-minute expiry using `ACCESS_TOKEN_SECRET`.
- **`isExpired(token)`** — Returns `true` if the token fails verification.
- **`refresh(token)`** — Decodes the existing token and issues a new one with a fresh expiry.

---

## Environment Variables

Create a `.env` file in this directory with the following:

```env
MONGODB_URI=your_mongodb_connection_string
ACCESS_TOKEN_SECRET=your_jwt_secret
```

These are never committed — `.gitignore` in this folder explicitly excludes `.env`.

---

## Prerequisites

- [Node.js](https://nodejs.org/) (v18+)
- [npm](https://www.npmjs.com/)
- A [MongoDB Atlas](https://www.mongodb.com/atlas) cluster with a database named `OutfittrDB`, containing collections `Users` and `Items`

---

## How to Run

```bash
cd backend
npm install
npm start
```

The server starts on `http://localhost:5000`.

---

## Database Structure

**Database:** `OutfittrDB`

| Collection | Fields |
|------------|--------|
| `Users` | `login`, `password`, `firstName`, `lastName` |
| `Items` | `Item`, `UserId` |
